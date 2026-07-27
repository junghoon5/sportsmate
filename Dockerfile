# ==========================================
# Stage 1: Build the React frontend
# ==========================================
FROM node:22-alpine AS frontend-builder

WORKDIR /app

# Copy the frontend package files & install dependencies
COPY frontend/package*.json ./frontend/
RUN cd frontend && npm install

# Copy frontend source code and build
COPY frontend/ ./frontend/
ARG VITE_API_BASE_URL=/api/v1
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL
RUN cd frontend && npm run build

# ==========================================
# Stage 2: Build the Python backend and serve
# ==========================================
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install Nginx and Supervisor for process management
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    supervisor \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy backend requirements and install them
COPY backend/requirements.txt ./backend/
RUN pip install --no-cache-dir -r backend/requirements.txt

# Copy the rest of the backend source code
COPY backend/ ./backend/

# Copy the built frontend static files to Nginx's default directory
COPY --from=frontend-builder /app/frontend/dist /usr/share/nginx/html

# ------------------------------------------
# Configure Nginx
# ------------------------------------------
RUN echo 'server {\n\
    listen 80;\n\
    server_name _;\n\
    root /usr/share/nginx/html;\n\
    index index.html;\n\
    client_max_body_size 20M;\n\
\n\
    # SPA fallback for React Router\n\
    location / {\n\
        try_files $uri $uri/ /index.html;\n\
    }\n\
\n\
    # Reverse proxy for backend API\n\
    location /api/ {\n\
        proxy_pass http://127.0.0.1:5000;\n\
        proxy_set_header Host $host;\n\
        proxy_set_header X-Real-IP $remote_addr;\n\
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n\
        proxy_set_header X-Forwarded-Proto $scheme;\n\
        proxy_read_timeout 300s;\n\
        proxy_connect_timeout 300s;\n\
    }\n\
}' > /etc/nginx/sites-available/default

# ------------------------------------------
# Configure Supervisor
# ------------------------------------------
RUN echo '[supervisord]\n\
nodaemon=true\n\
\n\
[program:nginx]\n\
command=nginx -g "daemon off;"\n\
autostart=true\n\
autorestart=true\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
stderr_logfile=/dev/stderr\n\
stderr_logfile_maxbytes=0\n\
\n\
[program:gunicorn]\n\
directory=/app/backend\n\
command=gunicorn -b 127.0.0.1:5000 --workers 4 --threads 2 --timeout 120 run:app\n\
autostart=true\n\
autorestart=true\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
stderr_logfile=/dev/stderr\n\
stderr_logfile_maxbytes=0\n' > /etc/supervisor/conf.d/supervisord.conf

# Expose port 80 for Nginx
EXPOSE 80

# Run Supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
