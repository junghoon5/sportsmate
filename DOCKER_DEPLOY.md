# SportsMate Docker Compose deployment

The frontend and backend are built as separate images. Backend secrets are
injected when the backend container starts and are not copied into either
image.

## 1. Prepare environment files

Keep the existing application environment files:

- `frontend/.env`: mounted as a BuildKit secret only while Vite builds.
- `backend/.env`: injected only when the backend container starts.

Neither file is copied into an image. Replace every placeholder in
`backend/.env`; it contains secrets such as `DATABASE_URL`, `JWT_SECRET_KEY`,
`SUPABASE_SERVICE_ROLE_KEY`, and external API keys.

Before pushing, replace the default `sportsmate` image namespace in
`docker-compose.yml` with your Docker Hub username, or set
`DOCKERHUB_USERNAME` in the terminal session.

## 2. Build and test locally

```bash
docker compose config
docker compose build
docker compose up -d
docker compose ps
docker compose logs -f
```

Open `http://localhost` or the configured `FRONTEND_PORT`.

## 3. Push the two images to Docker Hub

```bash
docker login
docker compose push
```

The image names are:

- `DOCKERHUB_USERNAME/sportsmate-backend:IMAGE_TAG`
- `DOCKERHUB_USERNAME/sportsmate-frontend:IMAGE_TAG`

## 4. Run on a deployment server

Copy these files to the server:

- `docker-compose.yml`
- `backend/.env` containing production runtime secrets

Then run:

```bash
docker compose pull
docker compose up -d
docker compose ps
```

The frontend Nginx container proxies `/api/*` to the Compose service named
`backend`, so the service name must remain unchanged.
