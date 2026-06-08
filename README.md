# Docker Apps - Core Self-Hosted Application Runtime

A Docker-based orchestration system for deploying core self-hosted services, with optional extra application catalogs. Built with Traefik reverse proxy, automatic SSL certificate management, GitHub Release bundles, and a unified command-line interface.

## 🎯 Key Features

- **Core Application Set** - Essential services for routing, auth, monitoring, automation, database access, error tracking, and analytics
- **Extra Application Bundles** - Optional release app catalogs can be merged during Ansible deploy
- **Traefik Reverse Proxy** - Automatic routing, SSL/TLS termination, and certificate management
- **Automatic SSL Certificates** - Support for Cloudflare DNS and Let's Encrypt HTTP challenges
- **Modular Architecture** - Reusable docker-compose components for easy maintenance and scaling
- **Environment-based Configuration** - Three-tier configuration cascade for flexibility
- **Persistent Data Management** - Organized storage with automatic backup-friendly structure
- **Database Integration** - PostgreSQL, Redis, MongoDB, TimescaleDB pre-configured
- **Health Checks** - Built-in health monitoring for all services
- **CI/CD Ready** - GitHub Actions workflow for automatic deployment via Tailscale

## 📋 Requirements

- **Docker** >= 20.10
- **Docker Compose** >= 2.0
- **Linux/macOS/WSL2** (Windows Subsystem for Linux 2)
- **2GB+ RAM** (recommended 4GB+ for production)
- **10GB+ Storage** (depending on applications and data)

## 🚀 Quick Start

### 1. Clone and Initialize

```bash
git clone https://github.com/dupmachine/docker-apps.git docker-apps
cd docker-apps
./up.sh
```

This will:
- Copy `.env.example` to `.env`
- Copy `apps.env.example` to `apps.env`
- Create `apps-data/` directory structure
- Create Docker networks
- Set up Traefik SSL configuration

### Release Bundle

Every push to `main` publishes a deployable project bundle as a GitHub Release asset:

```text
dupmachine/docker-apps@<short-sha>
dupmachine/docker-apps@latest
```

The release asset is `docker-apps.tar.gz` with the compose files and helper scripts, but not runtime state such as `.env`, `apps.env`, `apps-data/`, or `backups/`.

Download and unpack a bundle:

```bash
gh release download latest --repo dupmachine/docker-apps --pattern docker-apps.tar.gz
mkdir -p /opt/docker-apps/releases/latest
tar -xzf docker-apps.tar.gz -C /opt/docker-apps/releases/latest
```

### 2. Configure Environment

Edit `.env` with your settings:

```bash
# Domain configuration
APPS_DOMAIN=...

# SSL/TLS Configuration
APPS_CERTIFICATE_RESOLVER=...
APPS_CLOUDFLARE_DNS_API_TOKEN=...

# Database
APPS_DATABASE_PASSWORD=...

# System
APPS_TIMEZONE=...
```

### Ansible Deploy

The repository includes an Ansible playbook for deploying the published Docker Apps bundle and encrypted env package:

Target servers need Docker, Docker Compose, GitHub CLI (`gh`), SOPS, and the server-local age key.

```bash
ansible-playbook ansible/deploy-docker-apps.yml \
  -i mainframe, \
  -u root \
  -e docker_apps_env_ref=dupmachine/secrets@mainframe
```

The playbook pulls `docker_apps_app_ref` (`dupmachine/docker-apps@latest` by default), pulls the server-specific encrypted env release asset from `docker_apps_env_ref`, decrypts it with the server-local SOPS age key, links shared `.env`, `apps.env`, and `apps-data` into a timestamped release, switches `current`, and runs `./restart.sh`.

For now, `.env` is managed from the encrypted release asset, while `apps.env` remains persistent server state in `shared/apps.env` until the app list migration is completed.

For private GitHub Releases, pass a token through Ansible variables, for example from Semaphore UI secret variables:

```yaml
docker_apps_github_token: "{{ GITHUB_TOKEN }}"
```

When `docker_apps_github_token` is set, the playbook exports it as `GH_TOKEN` for `gh release download`. Public releases do not need this variable.

Optional extra app bundles can be merged into the release before restart:

```bash
ansible-playbook ansible/deploy-docker-apps.yml \
  -i mainframe, \
  -u root \
  -e docker_apps_env_ref=dupmachine/secrets@mainframe \
  -e '{"docker_apps_extra_refs":["dupmachine/docker-apps-extra@latest"]}'
```

Extra bundles must contain an `apps/` directory. Extra app names cannot conflict with apps from the core bundle or earlier extra bundles.

### 3. Select Applications

Edit `apps.env` and choose which apps to deploy:

```bash
APPS=(
	'traefik'           # Required - reverse proxy
	'gatus'             # Monitoring
	'beszel'            # Server monitoring
	'semaphore'         # Automation
	'rybbit'            # Analytics
	# Add more as needed...
)
```

### 4. Start Applications

```bash
# Start all configured apps (Traefik must be first)
./up.sh

# Or start specific apps
./up.sh traefik gatus rybbit

# View logs
./logs.sh gatus
```

All apps will be accessible at `https://{app-name}.{APPS_DOMAIN}`

> **Tip**: To override any global variable for a specific app without committing secrets, create `apps-data/{app}/.env`. For example, to run an app on a different domain: `echo "APPS_DOMAIN=other-domain.com" > apps-data/myapp/.env`

## 📁 Project Structure

```
docker-apps/
├── apps/                          # Application configurations
│   ├── traefik/                  # Reverse proxy & SSL
│   ├── common.yml               # Shared service definitions
│   ├── networks.yml             # Network configuration
│   ├── postgres.yml             # PostgreSQL template
│   ├── redis.yml                # Redis template
│   ├── mongodb.yml              # MongoDB template
│   └── {app-name}/              # Each app directory
│       ├── .env                 # App-specific variables
│       ├── docker-compose.yml   # App configuration
│       └── config/              # Optional config templates
│
├── apps-data/                     # Persistent data (git-ignored)
│   ├── traefik/                 # SSL certificates
│   ├── postgres/                # PostgreSQL data
│   └── {app-name}/              # Each app's data
│       ├── .env                 # Optional: per-app env overrides
│       └── ...                  # App data directories
│
├── backups/                       # Backup archives (git-ignored)
├── ansible/
│   └── deploy-docker-apps.yml      # Deploy published bundle and encrypted env
├── .github/
│   ├── actions/
│   │   ├── discover-manifest-matrix/  # Build a strategy matrix from files matching a glob
│   │   ├── publish-sops-env/          # Encrypt env manifest and upload to GitHub Release
│   │   └── publish-app-bundle/        # Build and publish a Docker Apps release bundle
│   └── workflows/
│       └── publish.yml             # Publish Docker Apps release bundle
│
├── .env                          # Global configuration (git-ignored)
├── .env.example                  # Configuration template
├── apps.env                      # App list (git-ignored)
├── apps.env.example             # App list template
│
├── up.sh                         # Start applications
├── down.sh                       # Stop applications
├── restart.sh                    # Restart applications
├── logs.sh                       # View application logs
└── backup.sh                     # Backup app data
```

## 🎮 Common Commands

### Start Applications

```bash
# Start all apps defined in APPS array (pulls latest images automatically)
./up.sh

# Start specific apps
./up.sh traefik gatus rybbit
```

### Stop Applications

```bash
# Stop all apps
./down.sh

# Stop specific apps
./down.sh gatus rybbit
```

### Restart Applications

```bash
# Restart all apps
./restart.sh

# Restart specific apps
./restart.sh gatus rybbit
```

### View Logs

```bash
# View logs for specific app (requires single app name)
./logs.sh gatus

# View logs with timestamps
./logs.sh rybbit
```

### Backup Applications

```bash
# Backup all apps from a remote server
./backup.sh user@server.com
```

The script stops each app one at a time, creates a zip archive, restarts it, then downloads the archive to `backups/`. Files are named `{server}-{app}-{datetime}.zip`.

## 📦 Core Applications
| Name | Purpose |
|------|---------|
| **traefik** | Reverse proxy & SSL |
| **semaphore** | Ansible UI & task runner |
| **2fauth** | Two-factor auth manager |
| **gatus** | Status page & health checks |
| **beszel** | Server monitoring |
| **beszel-agent** | Beszel remote agent |
| **glitchtip** | Error tracking |
| **databasus** | Database management UI |
| **rybbit** | Web analytics |

Additional apps live in the optional `dupmachine/docker-apps-extra` catalog and can be merged at deploy time with `docker_apps_extra_refs`.

## ⚙️ Configuration

### Environment Variables

Variables are applied in this order — each level overrides the previous:

**1. Global (`/.env`)**:
```bash
APPS_DOMAIN                 # Base domain (required)
APPS_CERTIFICATE_RESOLVER   # letsencrypt or cloudflare
APPS_CLOUDFLARE_DNS_API_TOKEN   # If using Cloudflare DNS
APPS_DATABASE_PASSWORD      # PostgreSQL/MySQL password
APPS_KEY_HEX_16             # 16-byte hex key for apps
APPS_KEY_HEX_32             # 32-byte hex key for apps
APPS_KEY_HEX_64             # 64-byte hex key for apps
APPS_TIMEZONE               # System timezone (UTC, etc.)
```

**2. Generated app env (`/apps/{app}/.env`)**:
```bash
APP_NAME   # Generated from the app folder name and used in URLs/paths
```

**3. Per-app overrides (`/apps-data/{app}/.env`)**:

Create this file to override any global variable for a specific app:
```bash
# apps-data/myapp/.env
APPS_DOMAIN=other-domain.com
```

This file is git-ignored and lives alongside app data, making it suitable for server-specific settings that shouldn't be committed.

### Network Architecture

- **traefik** - External network for reverse proxy communication
- **internal** - Isolated network for app-to-app communication
- **databases** - Dedicated network for database services (PostgreSQL, Redis, MongoDB)
- **mcp** - External network for MCP services consumed by MetaMCP

Apps are automatically connected to appropriate networks based on their needs.

## 🆕 Adding a New Application

### Step 1: Create App Directory

```bash
mkdir apps/{app-name}
```

### Step 2: Create `docker-compose.yml`

```yaml
# apps/myapp/docker-compose.yml
include:
  - ../networks.yml

x-environment: &environment
  MY_VAR: ${MY_VALUE}
  ANOTHER_VAR: value

services:
  myapp:
    image: myapp:latest
    extends:
      file: ../common.yml
      service: main
    expose:
      - 8080
    labels:
      - "traefik.http.services.${APP_NAME}.loadbalancer.server.port=8080"
    environment: *environment
    volumes:
      - ../../apps-data/${APP_NAME}/data:/data
```

### Step 3: Add to `apps.env`

```bash
APPS=(
  'traefik'
  'myapp'     # Add your new app
)
```

### Step 4: Start the App

```bash
./up.sh myapp
```

**Important**: Always use the `x-environment` anchor pattern for environment variables. This ensures consistency and reduces duplication.

## 🔍 Troubleshooting

### Container Won't Start

```bash
# Check logs
./logs.sh app-name

# Validate docker-compose configuration
docker compose --env-file ./apps/app-name/.env --env-file .env \
  -f ./apps/app-name/docker-compose.yml config

# Check network connectivity
docker network ls
docker network inspect traefik
```

### SSL Certificate Issues

```bash
# Check Traefik logs
./logs.sh traefik

# Verify ACME certificate file
ls -la apps-data/traefik/acme.json

# Ensure correct permissions
chmod 600 apps-data/traefik/acme.json

# For Cloudflare issues, verify API token is set in .env
grep APPS_CLOUDFLARE_DNS_API_TOKEN .env
```

### Application Not Accessible

1. Verify app is running: `docker ps | grep app-name`
2. Check app logs: `./logs.sh app-name`
3. Check Traefik logs: `./logs.sh traefik`
4. Verify DNS resolves: `nslookup app-name.domain.com`
5. Test internal connectivity: `docker exec -it traefik wget -q --spider http://app-name`

## 🔐 Security Best Practices

1. **Change Default Credentials** - Update passwords in `.env` and app configurations
2. **Use Strong Passwords** - Generate with: `openssl rand -base64 32`
3. **Keep Images Updated** - Run `./restart.sh` regularly (`up.sh` pulls latest images automatically)
4. **Restrict Network Access** - Use firewall rules to limit access to Traefik ports (80, 443)
5. **Enable HTTPS** - Always use HTTPS, never expose HTTP to internet
6. **Backup Data** - Regularly backup `apps-data/` directory
7. **Monitor Logs** - Review logs regularly for errors and unauthorized access attempts
8. **Update Dependencies** - Check for updates: `docker pull app:latest`

## 📚 Additional Resources

- [CLAUDE.md](CLAUDE.md) - Detailed technical documentation for developers
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Traefik Documentation](https://doc.traefik.io/)

## 🤝 Contributing

Contributions are welcome! To add a new application:

1. Follow the "Adding a New Application" section
2. Test thoroughly with `./up.sh app-name`
3. Document any special requirements
4. Submit a pull request with the new app configuration

## 🔄 Similar Services

If you're evaluating alternatives, these projects solve a similar problem from different angles:

| Service | Website | Focus | Service Templates |
|------|---------|---------|---------|
| **docker-apps** | This repository | Git-based Docker Compose stack with reusable templates and shell scripts | [apps](./apps/) |
| **Dokploy** | [dokploy.com](https://dokploy.com) | PaaS-style deployment panel for apps, databases, and containers | [Dokploy/templates/blueprints](https://github.com/Dokploy/templates/tree/canary/blueprints) |
| **Runtipi** | [runtipi.io](https://runtipi.io) | Beginner-friendly self-hosted app store and dashboard | [runtipi/runtipi-appstore/apps](https://github.com/runtipi/runtipi-appstore/tree/master/apps) |
| **Coolify** | [coolify.io](https://coolify.io) | Self-hosted Heroku/Vercel-style platform for apps, databases, and services | [coollabsio/coolify/templates/compose](https://github.com/coollabsio/coolify/tree/v4.x/templates/compose) |

## ⚙️ GitHub Actions

This repository provides three reusable composite actions under `.github/actions/`.

---

### `discover-manifest-matrix`

Builds a GitHub Actions strategy matrix from files matching a glob pattern.

```yaml
- id: discover
  uses: dupmachine/docker-apps/.github/actions/discover-manifest-matrix@main
  with:
    pattern: projects/*/*.yml   # required
```

**Outputs:** `matrix` — JSON object `{"manifest": ["path/a.yml", "path/b.yml", ...]}`.

**Typical use** — feed the output into a matrix job:

```yaml
jobs:
  discover:
    outputs:
      matrix: ${{ steps.discover.outputs.matrix }}
    steps:
      - uses: actions/checkout@v6
      - id: discover
        uses: dupmachine/docker-apps/.github/actions/discover-manifest-matrix@main
        with:
          pattern: projects/*/*.yml

  publish:
    needs: discover
    strategy:
      matrix: ${{ fromJson(needs.discover.outputs.matrix) }}
    steps:
      - run: echo ${{ matrix.manifest }}
```

---

### `publish-sops-env`

Renders an env manifest from GitHub Secrets/Variables, encrypts it with SOPS age recipients, and uploads `.sops.env` as a GitHub Release asset.

The release must already exist before this action runs. Create it in a separate job and pass the tag explicitly.

```yaml
- uses: dupmachine/docker-apps/.github/actions/publish-sops-env@main
  with:
    manifest: projects/docker-apps/mainframe.yml   # required
    keys-directory: keys                           # default: keys
    release-tag: latest                            # default: manifest release_tag or repo name
    release-repo: ""                               # default: current repository
    asset-name: ""                                 # default: manifest release_asset or <stem>.sops.env
    token: ${{ secrets.GITHUB_TOKEN }}             # required
  env:
    GITHUB_SECRETS_JSON: ${{ toJson(secrets) }}
    GITHUB_VARS_JSON: ${{ toJson(vars) }}
```

Requires `contents: write` permission on the calling job.

**Manifest format:**

```yaml
release_asset: docker-apps--mainframe.sops.env

keys:
  - master
  - mainframe

raw_env:        # optional — skip shell quoting for bash array values
  - APPS

env:
  APPS_DOMAIN: APPS_DOMAIN         # output name: GitHub Secret/Variable name
  APPS: APPS_AGATHA
```

Secrets take precedence over Variables when both contain the same source key. Every source key must exist or the action fails.

---

### `publish-app-bundle`

Builds a `tar.gz` bundle from specified paths and publishes it as a GitHub Release asset — once under an immutable short-SHA tag and once under a mutable `latest` tag.

```yaml
- uses: dupmachine/docker-apps/.github/actions/publish-app-bundle@main
  with:
    paths: |                        # required — newline-separated paths to include
      apps
      ansible
      *.sh
      *.env.example
    token: ${{ secrets.GITHUB_TOKEN }}   # required
    bundle-name: docker-apps.tar.gz      # default
    tag: ""                              # default: first 8 chars of GITHUB_SHA
    latest-tag: latest                   # default: latest (set to "" to disable)
    release-repo: ""                     # default: current repository
```

Requires `contents: write` permission on the calling job.

The action refuses bundles that contain `.env`, `apps.env`, `apps-data/`, or `backups/`.

**Outputs:** `tag` (immutable SHA tag used), `ref` (`owner/repo@tag`).

## 📝 License

This project is provided as-is for self-hosted deployment.

---

**Last Updated**: 2026
**Supported Docker Compose**: >= 2.0
**Status**: Active Development
