# Shroom Deployment Guide

## Docker Deployment

This guide covers deploying Shroom using Docker with a fully self-contained setup including the application and PostgreSQL with PostGIS.

### Prerequisites

- Docker Desktop (for Windows) or Docker Engine (for Linux)
- Docker Compose

### Quick Start

1. **Generate a secret key** (first time only):
   ```bash
   ./docker-setup.sh
   ```

   This will:
   - Generate a secure `SECRET_KEY_BASE`
   - Create the PostgreSQL data directory at `~/.shroom/postgres-data` (Windows: `%USERPROFILE%\.shroom\postgres-data`)
   - Build the Docker containers

2. **Update the secret key**:

   Edit `docker-compose.prod.yml` and replace:
   ```yaml
   SECRET_KEY_BASE: "CHANGE_ME_IN_PRODUCTION_USE_mix_phx_gen_secret_TO_GENERATE"
   ```

   With the generated key from step 1.

3. **Start the application**:
   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   ```

4. **Access the application**:

   Open your browser to [http://localhost:4000](http://localhost:4000)

### Management Commands

**View logs**:
```bash
docker-compose -f docker-compose.prod.yml logs -f
```

**Stop the application**:
```bash
docker-compose -f docker-compose.prod.yml down
```

**Restart the application**:
```bash
docker-compose -f docker-compose.prod.yml restart
```

**Run database migrations** (if needed):
```bash
docker-compose -f docker-compose.prod.yml exec app /app/bin/migrate
```

**Access the app console**:
```bash
docker-compose -f docker-compose.prod.yml exec app /app/bin/shroom remote
```

**Rebuild after code changes**:
```bash
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d
```

### Data Persistence

PostgreSQL data is stored outside the container in:
- **Windows**: `%USERPROFILE%\.shroom\postgres-data` (e.g., `C:\Users\YourName\.shroom\postgres-data`)
- **Linux/Mac**: `~/.shroom/postgres-data`

This ensures your data persists even if you remove the containers.

### Backup and Restore

**Backup database**:
```bash
docker-compose -f docker-compose.prod.yml exec postgres pg_dump -U postgres shroom_prod > backup.sql
```

**Restore database**:
```bash
docker-compose -f docker-compose.prod.yml exec -T postgres psql -U postgres shroom_prod < backup.sql
```

### Production Configuration

For production deployment, update these environment variables in `docker-compose.prod.yml`:

1. **SECRET_KEY_BASE**: Use the generated secret (never commit the real secret to git!)
2. **RELEASE_COOKIE**: Change to a unique value
3. **PHX_HOST**: Set to your domain name (e.g., `shroom.example.com`)
4. **Database password**: Change `POSTGRES_PASSWORD` to a strong password

### Troubleshooting

**Check container status**:
```bash
docker-compose -f docker-compose.prod.yml ps
```

**Check database connectivity**:
```bash
docker-compose -f docker-compose.prod.yml exec postgres psql -U postgres -c "SELECT version();"
```

**Reset everything** (⚠️ This will delete all data):
```bash
docker-compose -f docker-compose.prod.yml down -v
rm -rf ~/.shroom/postgres-data  # Or %USERPROFILE%\.shroom\postgres-data on Windows
./docker-setup.sh
```

### Port Configuration

The default ports are:
- **Application**: 4000
- **PostgreSQL**: 5432

To change these, edit the `ports` section in `docker-compose.prod.yml`.

### SSL/HTTPS

For production use with HTTPS, consider using:
- Nginx or Caddy as a reverse proxy
- Let's Encrypt for SSL certificates
- Update `PHX_HOST` and configure SSL termination at the proxy level

## Manual Deployment (Without Docker)

If you prefer to deploy without Docker:

1. **Build the release**:
   ```bash
   MIX_ENV=prod mix assets.deploy
   MIX_ENV=prod mix release
   ```

2. **Copy the tarball** to your server:
   ```bash
   scp _build/prod/shroom-0.1.0.tar.gz user@server:/opt/shroom/
   ```

3. **On the server**, extract and configure:
   ```bash
   cd /opt/shroom
   tar -xzf shroom-0.1.0.tar.gz

   # Set environment variables
   export DATABASE_URL="ecto://user:pass@localhost/shroom_prod"
   export SECRET_KEY_BASE="your-secret-key"
   export PHX_HOST="your-domain.com"

   # Run migrations
   bin/migrate

   # Start the application
   bin/shroom start
   ```

## Environment Variables Reference

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `DATABASE_URL` | PostgreSQL connection string | Yes | - |
| `SECRET_KEY_BASE` | Phoenix secret key | Yes | - |
| `PHX_HOST` | Hostname for the application | Yes | localhost |
| `PHX_SERVER` | Enable Phoenix server | No | true |
| `PORT` | HTTP port | No | 4000 |
| `RELEASE_COOKIE` | Erlang distribution cookie | No | - |
