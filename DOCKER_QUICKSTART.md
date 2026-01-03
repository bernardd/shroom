# Docker Quick Start

Get Shroom running in Docker in 3 steps:

## Step 1: Generate Secret Key

Run the setup script:
```bash
./docker-setup.sh
```

Copy the generated `SECRET_KEY_BASE` value.

## Step 2: Update Configuration

Edit `docker-compose.prod.yml` and replace:
```yaml
SECRET_KEY_BASE: "CHANGE_ME_IN_PRODUCTION_USE_mix_phx_gen_secret_TO_GENERATE"
```

With your generated key (keep it secret!).

## Step 3: Start the Application

```bash
docker-compose -f docker-compose.prod.yml up -d
```

Visit [http://localhost:4000](http://localhost:4000) 🍄

## Data Location

Your PostgreSQL data is stored at:
- **Windows**: `C:\Users\<YourName>\.shroom\postgres-data`
- **Linux/WSL**: `~/.shroom/postgres-data`

## Common Commands

```bash
# View logs
docker-compose -f docker-compose.prod.yml logs -f

# Stop
docker-compose -f docker-compose.prod.yml down

# Restart
docker-compose -f docker-compose.prod.yml restart
```

See [DEPLOYMENT.md](DEPLOYMENT.md) for full documentation.
