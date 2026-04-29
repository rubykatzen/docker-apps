# Docker Apps - Self-Hosted Application Management System

A comprehensive Docker-based orchestration system for deploying and managing 70+ self-hosted applications. Built with Traefik reverse proxy, automatic SSL certificate management, and a unified command-line interface.

## 🎯 Key Features

- **70+ Pre-configured Applications** - Ready-to-deploy services including monitoring, automation, media, CRM, and more
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
git clone https://github.com/rubycats-com/docker-apps.git docker-apps
cd docker-apps
bash init.sh
```

This will:
- Copy `.env.example` to `.env`
- Copy `apps.env.example` to `apps.env`
- Create `apps-data/` directory structure
- Create Docker networks
- Set up Traefik SSL configuration

### 2. Configure Environment

Edit `.env` with your settings:

```bash
# Domain configuration
DAPPS_DOMAIN=example.com

# SSL/TLS Configuration
DAPPS_CERTIFICATE_RESOLVER=letsencrypt  # or cloudflare
DAPPS_CLOUDFLARE_DNS_API_TOKEN=your_token   # if using Cloudflare

# Database
DAPPS_DATABASE_PASSWORD=your_secure_password

# System
DAPPS_TIMEZONE=UTC
```

### 3. Select Applications

Edit `apps.env` and choose which apps to deploy:

```bash
DAPPS=(
	'traefik'           # Required - reverse proxy
	'portainer'         # Container management
	'uptime-kuma'       # Monitoring
	'n8n'              # Workflow automation
	'jellyfin'         # Media server
	# Add more as needed...
)
```

### 4. Start Applications

```bash
# Start all configured apps (Traefik must be first)
./up.sh

# Or start specific apps
./up.sh traefik portainer uptime-kuma

# View logs
./logs.sh portainer
```

All apps will be accessible at `https://{app-name}.{DAPPS_DOMAIN}`

> **Tip**: To override any global variable for a specific app without committing secrets, create `apps-data/{app}/.env`. For example, to run an app on a different domain: `echo "DAPPS_DOMAIN=other-domain.com" > apps-data/myapp/.env`

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
├── backup.sh                     # Backup app data
└── init.sh                       # Initial setup
```

## 🎮 Common Commands

### Start Applications

```bash
# Start all apps defined in DAPPS array (pulls latest images automatically)
./up.sh

# Start specific apps
./up.sh traefik portainer n8n
```

### Stop Applications

```bash
# Stop all apps
./down.sh

# Stop specific apps
./down.sh jellyfin metabase
```

### Restart Applications

```bash
# Restart all apps
./restart.sh

# Restart specific apps
./restart.sh n8n portainer
```

### View Logs

```bash
# View logs for specific app (requires single app name)
./logs.sh portainer

# View logs with timestamps
./logs.sh n8n
```

### Backup Applications

```bash
# Backup all apps from a remote server
./backup.sh user@server.com
```

The script stops each app one at a time, creates a zip archive, restarts it, then downloads the archive to `backups/`. Files are named `{server}-{app}-{datetime}.zip`.

## 📦 Available Applications
| Name | Purpose |
|------|---------|
| **traefik** | Reverse proxy & SSL |
| **portainer** | Container management |
| **watchtower** | Automatic image updates |
| **uptime-kuma** | Monitoring & alerts |
| **gatus** | Status page & health checks |
| **beszel** | Server monitoring |
| **beszel-agent** | Beszel remote agent |
| **scrutiny** | Disk health monitor |
| **speedtest-tracker** | Speedtest monitor |
| **n8n** | Workflow automation |
| **activepieces** | Workflow automation |
| **automatisch** | Workflow automation |
| **semaphore** | Ansible UI & task runner |
| **jellyfin** | Media server |
| **jellyseerr** | Media request manager |
| **radarr** | Movie management |
| **sonarr** | TV show management |
| **prowlarr** | Indexer manager |
| **bazarr** | Subtitle manager |
| **seerr** | Unified media requests |
| **stash** | Adult media organizer |
| **metube** | YouTube downloader |
| **audiobookshelf** | Audiobook server |
| **qbittorrent** | Torrent client |
| **qbittorrent-vpn** | Torrent client with VPN |
| **icloudpd** | iCloud photo downloader |
| **immich** | Photo backup & management |
| **rotki** | Crypto portfolio tracker |
| **yamtrack** | Media tracker |
| **homarr** | Dashboard |
| **homer** | Home page |
| **homepage** | Home page |
| **glance** | Dashboard |
| **freshrss** | RSS reader |
| **rssbox** | RSS aggregator |
| **rsshub** | RSS feed generator |
| **changedetection** | Website monitor |
| **grocy** | Inventory manager |
| **tandoor** | Recipe manager |
| **kimai** | Time tracking |
| **solidtime** | Time tracking |
| **monica** | Personal CRM |
| **metabase** | Analytics dashboard |
| **umami** | Web analytics |
| **openpanel** | Web analytics |
| **rybbit** | Web analytics |
| **countly** | Mobile & web analytics |
| **chatwoot** | Customer messaging |
| **formbricks** | Form & survey builder |
| **wallos** | Subscription tracker |
| **infisical** | Secrets management |
| **authentik** | Identity provider |
| **2fauth** | Two-factor auth manager |
| **outline-admin** | Wiki / knowledge base |
| **growthbook** | Feature flags & A/B testing |
| **unleash** | Feature flag management |
| **codecov** | Code coverage |
| **airbroke** | Error tracking |
| **glitchtip** | Error tracking |
| **bugsink** | Error tracking |
| **sentry (sure)** | Error tracking |
| **databasus** | Database management UI |
| **pgbouncer** | PostgreSQL connection pooler |
| **home-assistant** | Home automation |
| **wireguard** | VPN server |
| **amnezia** | VPN server |
| **ipsec-vpn-server** | IPSec VPN server |
| **sshd-proxy** | SSH proxy |
| **virtual-dsm** | Virtual DSM (Synology) |
| **windows** | Windows VM |
| **lobehub** | AI chat with multi-provider support |
| **metamcp** | MCP server aggregator & manager |
| **omniroute** | AI provider proxy & router |
| **paperclip** | AI coding assistant |
| **playwright** | Playwright MCP browser automation |
| **flaresolverr** | Cloudflare bypass proxy |
| **whoami** | Debug/test |

*See each app's directory for current status and additional options*

## ⚙️ Configuration

### Environment Variables

Variables are applied in this order — each level overrides the previous:

**1. Global (`/.env`)**:
```bash
DAPPS_DOMAIN                 # Base domain (required)
DAPPS_CERTIFICATE_RESOLVER   # letsencrypt or cloudflare
DAPPS_CLOUDFLARE_DNS_API_TOKEN   # If using Cloudflare DNS
DAPPS_DATABASE_PASSWORD      # PostgreSQL/MySQL password
DAPPS_KEY_HEX_16             # 16-byte hex key for apps
DAPPS_KEY_HEX_32             # 32-byte hex key for apps
DAPPS_KEY_HEX_64             # 64-byte hex key for apps
DAPPS_TIMEZONE               # System timezone (UTC, etc.)
```

**2. App-specific (`/apps/{app}/.env`)**:
```bash
APP_NAME   # Application identifier (used in URLs)
APP_PORT   # Internal container port
```

**3. Per-app overrides (`/apps-data/{app}/.env`)**:

Create this file to override any global variable for a specific app:
```bash
# apps-data/myapp/.env
DAPPS_DOMAIN=other-domain.com
```

This file is git-ignored and lives alongside app data, making it suitable for server-specific settings that shouldn't be committed.

Apps that extend `main-bearer` also read `APP_BEARER_TOKEN` from this file:
```bash
# apps-data/myapp/.env
APP_BEARER_TOKEN=your-long-random-token
```
Playwright MCP is intended for internal Docker network use, for example from MetaMCP via `http://playwright:8931/mcp`.

### Network Architecture

- **traefik** - External network for reverse proxy communication
- **internal** - Isolated network for app-to-app communication
- **databases** - Dedicated network for database services (PostgreSQL, Redis, MongoDB)

Apps are automatically connected to appropriate networks based on their needs.

## 🆕 Adding a New Application

### Step 1: Create App Directory

```bash
mkdir apps/{app-name}
```

### Step 2: Create `.env` File

```bash
# apps/{app-name}/.env
APP_NAME=myapp
APP_PORT=8080
```

### Step 3: Create `docker-compose.yml`

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
    environment: *environment
    volumes:
      - ../../apps-data/${APP_NAME}/data:/data
```

### Step 4: Add to `apps.env`

```bash
DAPPS=(
  'traefik'
  'myapp'     # Add your new app
)
```

### Step 5: Start the App

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
grep DAPPS_CLOUDFLARE_DNS_API_TOKEN .env
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

## 📝 License

This project is provided as-is for self-hosted deployment.

---

**Last Updated**: 2026
**Supported Docker Compose**: >= 2.0
**Status**: Active Development
