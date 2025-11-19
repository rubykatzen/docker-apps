# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Docker-based application management system (docker-apps) that orchestrates multiple self-hosted services using docker-compose. The architecture uses Traefik as a reverse proxy with automatic SSL certificate management, and provides a unified management interface for deploying and managing 50+ different applications.

## Core Architecture

### Directory Structure
- `apps/` - Contains docker-compose configurations for each application
- `apps-data/` - Persistent data storage for all running applications
- `.env` - Global environment variables (domain, credentials, SSL settings)
- `apps.env` - List of applications to deploy (DAPPS array)
- Shell scripts at root for orchestration

### Docker Compose Architecture
The repository uses a modular docker-compose structure with reusable components:

1. **Common Service Definitions** (`apps/common.yml`):
   - `x-healthcheck`: Universal health check logic supporting multiple tools (curl, wget, nc, etc.)
   - `x-labels`: Traefik labels for routing and SSL
   - `x-restart`: Restart policy (unless-stopped)
   - Pre-defined service profiles: `main`, `host`, `side`

2. **Shared Infrastructure** (`apps/networks.yml`, `apps/postgres.yml`, `apps/redis.yml`):
   - `networks.yml`: Defines `internal`, `databases`, and `traefik` networks
   - `postgres.yml`: PostgreSQL 17 service template
   - `redis.yml`: Redis 7 service template
   - Apps include these via `include:` directive to get database/cache services

3. **App Structure Pattern**:
   Each app in `apps/` has:
   - `.env` file with `APP_NAME` and `APP_PORT`
   - `docker-compose.yml` extending common services
   - Optional `config/` with template files (`.template.yml`)

### Environment Variable System

Three-tier environment variable cascade:
1. `.env` - Global settings (DAPPS_* variables for domain, database password, API keys)
2. `apps.env` - DAPPS array defining which apps to deploy
3. `apps/{app}/.env` - App-specific variables (APP_NAME, APP_PORT)

Key global variables in `.env`:
- `DAPPS_DOMAIN` - Base domain for all services
- `DAPPS_CERTIFICATE_RESOLVER` - SSL resolver (Cloudflare DNS or HTTP challenge)
- `DAPPS_DATABASE_PASSWORD` - Shared database password
- `DAPPS_KEY_HEX_{16,32,64}` - Encryption keys for various apps
- `DAPPS_TIMEZONE` - System timezone

### Traefik Integration

All apps use Traefik labels pattern:
```yaml
traefik.enable=true
traefik.http.routers.${APP_NAME}.rule=Host(`${APP_NAME}.${DAPPS_DOMAIN}`)
traefik.http.routers.${APP_NAME}.tls.certresolver=${DAPPS_CERTIFICATE_RESOLVER}
traefik.http.services.${APP_NAME}.loadbalancer.server.port=${APP_PORT}
```

Apps are accessible at `{app-name}.{DAPPS_DOMAIN}` with automatic SSL.

## Common Commands

### Starting Applications
```bash
# Start all apps defined in DAPPS array in apps.env
./up.sh

# Start specific app(s)
./up.sh traefik portainer n8n
```

The `up.sh` script:
- Sources environment variables from .env and apps.env
- Processes config templates using envsubst (files matching `*.template.*`)
- Creates apps-data directories
- Runs docker compose up for each app with merged env files

### Stopping Applications
```bash
# Stop all apps
./down.sh

# Stop specific app(s)
./down.sh traefik portainer
```

### Restarting Applications
```bash
# Restart all apps (down + up)
./restart.sh

# Restart specific app(s)
./restart.sh n8n
```

### Viewing Logs
```bash
# View logs for a specific app (requires single app name)
./logs.sh portainer
```

### Updating Applications
```bash
# Pull latest images and restart all apps
./update.sh
```

### Manual Docker Compose Commands
When working with individual apps directly:
```bash
# Must provide both env files and specify app path
docker compose --env-file ./apps/{app}/.env --env-file .env -f ./apps/{app}/docker-compose.yml [command]

# Examples:
docker compose --env-file ./apps/n8n/.env --env-file .env -f ./apps/n8n/docker-compose.yml logs -f
docker compose --env-file ./apps/traefik/.env --env-file .env -f ./apps/traefik/docker-compose.yml restart
```

## Initial Setup

For first-time setup (documented in `init.sh`):
```bash
cp .env.example .env
cp apps.env.example apps.env
# Edit .env and apps.env with your configuration
mkdir apps-data
mkdir apps-data/traefik
touch apps-data/traefik/acme.json
chmod 600 apps-data/traefik/acme.json
docker network create traefik
```

## Adding New Applications

1. Create directory: `apps/{app-name}/`
2. Create `.env` with `APP_NAME` and `APP_PORT`
3. Create `docker-compose.yml`:
   - Include `../networks.yml` for network definitions
   - Extend `../common.yml` service definitions (usually `main`)
   - Include `../postgres.yml` and/or `../redis.yml` if needed
   - Reference data path: `../../apps-data/${APP_NAME}/`
4. Add app name to `DAPPS` array in `apps.env`
5. If app needs configuration templates, create `config/{name}.template.yml` (envsubst will process)

Example minimal app structure:
```yaml
include:
  - ../networks.yml
services:
  myapp:
    extends:
      file: ../common.yml
      service: main
    image: myapp:latest
    volumes:
      - ../../apps-data/${APP_NAME}/data:/data
```

## CI/CD

GitHub Actions workflow (`.github/workflows/cd.yml`) automatically deploys on push to main:
1. Connects via Tailscale VPN
2. Creates .env from GitHub secrets/vars
3. Uploads .env via SSH
4. Pulls latest code and runs `./restart.sh`

## Notable App Configurations

- **n8n**: Uses worker mode with Redis queue (`n8n` + `n8n-worker` services)
- **traefik**: Entry point, must be started first, uses external network
- Apps with databases include postgres.yml and create app-specific database named `${APP_NAME}`
- Config templates use `envsubst` - variables must be shell-compatible (`${VAR}` syntax)
