# Docker Apps - Self-Hosted Application Management System

A comprehensive Docker-based orchestration system for deploying and managing 50+ self-hosted applications. Built with Traefik reverse proxy, automatic SSL certificate management, and a unified command-line interface.

## 🎯 Key Features

- **50+ Pre-configured Applications** - Ready-to-deploy services including monitoring, automation, media, CRM, and more
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
git clone <repository-url> docker-apps
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
DAPPS_CLOUDFLARE_API_TOKEN=your_token   # if using Cloudflare

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
├── update.sh                     # Update images
└── init.sh                       # Initial setup
```

## 🎮 Common Commands

### Start Applications

```bash
# Start all apps defined in DAPPS array
./up.sh

# Start specific apps
./up.sh traefik portainer n8n

# Start app with dependencies
./up.sh jellyfin  # Pulls and starts jellyfin and its dependencies
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

# Follow logs in real-time
docker compose --env-file ./apps/portainer/.env --env-file .env \
  -f ./apps/portainer/docker-compose.yml logs -f
```

### Update Applications

```bash
# Pull latest images and restart all apps
./update.sh

```

## 📦 Available Applications
| Name | Purpose | 
|------|---------|
| **traefik** | Reverse proxy & SSL |
| **portainer** | Container management |
| **uptime-kuma** | Monitoring & alerts |
| **n8n** | Workflow automation | 
| **jellyfin** | Media server | 
| **metabase** | Analytics dashboard |
| **homarr** | Dashboard | 
| **homer** | Home page |
| **freshrss** | RSS reader |
| **grocy** | Inventory manager |
| **kimai** | Time tracking | 
| **monica** | CRM | PostgreSQL | 
| **radarr** | Movie management | 
| **sonarr** | TV show management |
| **prowlarr** | Indexer manager |
| **bazarr** | Subtitle manager | 
| **metube** | YouTube downloader |
| **qbittorrent** | Torrent client | 
| **changedetection** | Website monitor |
| **umami** | Analytics | PostgreSQL | 
| **audiobookshelf** | Audiobook server | 
| **wallos** | Subscription tracker |
| **beszel** | Server monitoring | 
| **scrutiny** | Disk health monitor |
| **speedtest-tracker** | Speedtest monitor |
| **home-assistant** | Home automation | 
| **infisical** | Secrets management | 
| **chatwoot** | Customer messaging | 
| **whoami** | Debug/test |

*See each app's directory for current status and additional options*

## ⚙️ Configuration

### Environment Variables

**Global (`/.env`)**:
```bash
DAPPS_DOMAIN                 # Base domain (required)
DAPPS_CERTIFICATE_RESOLVER   # letsencrypt or cloudflare
DAPPS_CLOUDFLARE_API_TOKEN   # If using Cloudflare DNS
DAPPS_DATABASE_PASSWORD      # PostgreSQL/MySQL password
DAPPS_KEY_HEX_16             # 16-byte hex key for apps
DAPPS_KEY_HEX_32             # 32-byte hex key for apps
DAPPS_KEY_HEX_64             # 64-byte hex key for apps
DAPPS_TIMEZONE               # System timezone (UTC, etc.)
```

**App-specific (`/apps/{app}/.env`)**:
```bash
APP_NAME   # Application identifier (used in URLs)
APP_PORT   # Internal container port
```

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
    extends:
      file: ../common.yml
      service: main
    image: myapp:latest
    environment: *environment
    volumes:
      - ../../apps-data/${APP_NAME}/data:/data
    # Add ports if needed
    expose:
      - ${APP_PORT}
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
grep DAPPS_CLOUDFLARE_API_TOKEN .env
```

### Application Not Accessible

1. Verify app is running: `docker ps | grep app-name`
2. Check app logs: `./logs.sh app-name`
3. Check Traefik logs: `./logs.sh traefik`
4. Verify DNS resolves: `nslookup app-name.domain.com`
5. Test internal access: `docker exec -it traefik ping app-name`

## 🔐 Security Best Practices

1. **Change Default Credentials** - Update passwords in `.env` and app configurations
2. **Use Strong Passwords** - Generate with: `openssl rand -base64 32`
3. **Keep Images Updated** - Run `./update.sh` regularly
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

## 📝 License

This project is provided as-is for self-hosted deployment.

---

**Last Updated**: 2024
**Supported Docker Compose**: >= 2.0
**Status**: Active Development