# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## Repository Overview

This is a Docker-based application management system (docker-apps) that orchestrates multiple self-hosted services using docker-compose. The architecture uses Traefik as a reverse proxy with automatic SSL certificate management, and provides a unified management interface for deploying and managing 70+ different applications.

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
   - Pre-defined service profiles: `main`, `main-http`, `main-bearer`, `api`, `host`, `side`

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

Four-tier environment variable cascade (each level overrides the previous):
1. `.env` - Global settings (DAPPS_* variables for domain, database password, API keys)
2. `apps.env` - DAPPS array defining which apps to deploy
3. `apps/{app}/.env` - App-specific variables (APP_NAME, APP_PORT)
4. `apps-data/{app}/.env` - Per-app runtime overrides (git-ignored, server-specific, e.g. different DAPPS_DOMAIN)

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

Apps that extend `main-bearer` are also routed through Traefik, but their HTTPS router requires `Authorization: Bearer ${APP_BEARER_TOKEN}`. Store `APP_BEARER_TOKEN` in `apps-data/{app}/.env`, not in committed files.

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
# up.sh pulls latest images automatically before starting
./restart.sh
```

### Manual Docker Compose Commands
When working with individual apps directly:
```bash
# Must provide env files in cascade order and specify app path
docker compose --env-file .env --env-file ./apps/{app}/.env --env-file ./apps-data/{app}/.env -f ./apps/{app}/docker-compose.yml [command]

# Examples:
docker compose --env-file .env --env-file ./apps/n8n/.env -f ./apps/n8n/docker-compose.yml logs -f
docker compose --env-file .env --env-file ./apps/traefik/.env -f ./apps/traefik/docker-compose.yml restart
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
   - Extend `../common.yml` service definitions (usually `main`, or `main-bearer` when the route must require a bearer token)
   - Include `../postgres.yml` and/or `../redis.yml`, `../mongo.yml` if needed
   - Reference data path: `../../apps-data/${APP_NAME}/`
4. Add app name to `DAPPS` array in `apps.env`
5. **If app uses PostgreSQL**: Add database entry to `apps/pgbouncer/config/pgbouncer.template.ini`:
   ```ini
   # For standard postgres.yml:
   appname = host=appname-postgres port=5432 dbname=appname user=appname password=${DAPPS_DATABASE_PASSWORD}
   
   # For pgvector.yml:
   appname = host=appname-pgvector port=5432 dbname=appname user=appname password=${DAPPS_DATABASE_PASSWORD}
   
   # For timescale.yml:
   appname = host=appname-timescale port=5432 dbname=appname user=appname password=${DAPPS_DATABASE_PASSWORD}
   ```
6. If app needs configuration templates, create `config/{name}.template.yml` (envsubst will process)

Example minimal app structure:
```yaml
include:
  - ../networks.yml
x-environment: &environment
  SOME_VAR: ${SOME_VALUE}
  ANOTHER_VAR: value
services:
  myapp:
    extends:
      file: ../common.yml
      service: main
    image: myapp:latest
    environment: *environment
    volumes:
      - ../../apps-data/${APP_NAME}/data:/data
```

**IMPORTANT: Always use x-environment anchor pattern for environment variables:**
- Declare environment variables once using `x-environment: &environment` at the top of the file
- Reference them in services using `environment: *environment`
- This ensures consistency, reduces duplication, and makes maintenance easier
- Even for single-service apps, use this pattern for consistency across the codebase

## Docker Compose Field Ordering Rules

To maintain consistency across all applications, follow these strict field ordering rules:

### File-level field order:
```yaml
# 1. INCLUDE DIRECTIVES (always first)
include:
  - ../networks.yml      # Always first
  - ../postgres.yml      # If PostgreSQL needed
  - ../redis.yml         # If Redis needed
  - ../mongo.yml         # If MongoDB needed

# 2. X-IMAGE (if multiple services use the same image)
x-image: &image
  organization/app:1.0

# 3. X-ENVIRONMENT (only if environment variables exist)
x-environment: &environment
  VAR1: ${VALUE1}
  DATABASE_URL: postgresql://postgres:${DAPPS_DATABASE_PASSWORD}@postgres:5432/${APP_NAME}

# 4. X-VOLUMES (if multiple services share volumes)
x-volumes: &volumes
  - ../../apps-data/${APP_NAME}/data:/data

# 5. SERVICES
services:
  # ... service definitions
```

### Service-level field order:
```yaml
services:
  app:
    # 1. IMAGE (required)
    image: organization/image:tag
    
    # 2. EXTENDS (if used)
    extends:
      file: ../common.yml
      service: main  # main | main-http | main-bearer | api | host | side
    
    # 3. COMMAND (if overriding)
    command: ["start", "--config", "/config.yml"]
    
    # 4. USER (if required)
    user: "${DAPPS_UID}:${DAPPS_GID}"
    
    # 5. ENVIRONMENT (mandatory, via anchor)
    environment: *environment
    
    # 6. PORTS (only for profile: host)
    ports:
      - "${APP_PORT}:8080"
    
    # 7. VOLUMES (order: data → configs → templates)
    volumes:
      - ../../apps-data/${APP_NAME}/data:/data
      - ../../apps-data/${APP_NAME}/config:/config
      - ./config/app.template.yml:/app/config.yml:ro
    
    # 8. NETWORKS (inherited from extends, omit this section)
    
    # 9. DEPENDS_ON (order: postgres → redis → mongo → others, simple list without condition)
    depends_on:
      - postgres
      - redis
    
    # 10. EXTRA_HOSTS (if host access needed)
    extra_hosts:
      - "host.docker.internal:host-gateway"
```

### Key ordering principles:
1. **Include order**: networks.yml → postgres.yml → redis.yml → mongo.yml
2. **X-fields order**: x-image → x-environment → x-volumes (only if needed)
3. **X-image for shared images** - if multiple services use the same image, use `x-image: &image`
4. **X-volumes for shared volumes** - if 2+ volumes repeat across services, extract them to `x-volumes: &volumes` and merge with unique ones
5. **Image before extends** - declare what image is used, then extend common config
6. **Environment via anchor** - always use `x-environment: &environment` pattern
7. **Networks from extends** - `main`, `main-http`, `main-bearer`, and `api` profiles include `traefik` and `internal`; never add `databases` (it's only for DB admin tools)
8. **Depends_on as simple list** - use array format without `condition:`, healthchecks are in common.yml
9. **Depends_on order**: postgres → redis → mongo → app services
10. **Volumes order**: data directories → config directories → template files (with :ro)
11. **Paths use ${APP_NAME}** - for reusability across apps

### YAML formatting rules:
1. **No quotes unless necessary** - avoid quotes around strings when YAML doesn't require them
2. **Double quotes when needed** - use double quotes `"` (not single) when quotes are required
3. **Omit :latest tag** - `image: traefik` instead of `image: traefik:latest`
4. **Variables always in quotes** - `"${APP_NAME}"` for shell variable interpolation
5. **Arrays use bracket notation** - `command: ["start", "--config"]` for commands (always single line)
6. **Booleans without quotes** - `true` and `false`, not `"true"` or `"false"`
7. **No empty lines in .yml files** - remove all blank lines, keep file compact without any empty line breaks
8. **No trailing spaces** - remove all trailing whitespace
9. **Restart policy** - if used, always `restart: unless-stopped` (not `always`)
10. **Volume paths consistency** - host folder name must match container mount point: `../../apps-data/${APP_NAME}/data:/data` (both are `data`), not `../../apps-data/${APP_NAME}/app-data:/data` or `../../apps-data/${APP_NAME}/library:/data`

Example:
```yaml
include:
  - ../networks.yml
  - ../postgres.yml
x-environment: &environment
  DATABASE_URL: postgresql://postgres:${DAPPS_DATABASE_PASSWORD}@postgres:5432/${APP_NAME}
  ENABLE_FEATURE: true
  PORT: 8080
services:
  app:
    image: organization/app:1.0
    extends:
      file: ../common.yml
      service: main
    command: ["worker", "--concurrency", "10"]
    user: "${DAPPS_UID}:${DAPPS_GID}"
    environment: *environment
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

- **traefik**: Entry point, must be started first, uses external network
- Apps with databases include postgres.yml and create app-specific database named `${APP_NAME}`
- Config templates use `envsubst` - variables must be shell-compatible (`${VAR}` syntax)

## Important: Template Files vs Generated Files

**CRITICAL**: When updating application configurations, always edit the `.template.*` files in `apps/{app}/config/`, NOT the generated files in `apps-data/{app}/config/`.

- Template files are located in: `apps/{app}/config/*.template.*`
- Generated files are created in: `apps-data/{app}/config/`
- The `up.sh` script automatically processes templates using `envsubst` and outputs to `apps-data/`
- Editing generated files directly will result in lost changes on next restart
- Always modify templates, then run `./restart.sh {app}` to regenerate
