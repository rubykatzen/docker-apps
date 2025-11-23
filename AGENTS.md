# Repository Guidelines

## Project Structure & Module Organization
- Core app bundles live in `apps/{app-name}/` with `.env`, `docker-compose.yml`, and optional `config/`. Shared fragments: `apps/common.yml`, `apps/networks.yml`, `apps/{postgres,redis,mongodb}.yml`.
- Data mounts stay in `apps-data/{app-name}/` (git-ignored). Do not commit runtime artifacts.
- Root scripts (`up.sh`, `down.sh`, `restart.sh`, `logs.sh`, `init.sh`, `update.sh`) are the supported entry points. Env templates live in `.env.example` and `apps.env.example`.

## Build, Test, and Development Commands
- `bash init.sh` — bootstrap env, copy templates, create data dirs and networks.
- `./up.sh [app ...]` — start all configured apps or a subset (Traefik first).
- `./down.sh [app ...]` / `./restart.sh [app ...]` — stop or restart selected services.
- `./logs.sh app-name` — compose-aware logs for one app.
- `./update.sh` — pull images and recycle running apps.
- Compose lint: `docker compose --env-file ./apps/{app}/.env --env-file .env -f ./apps/{app}/docker-compose.yml config`.

## Coding Style & Naming Conventions
- YAML uses 2-space indent; keep `include`/`extends` and the `x-environment` anchor pattern to avoid duplication.
- Directory name, service name, and `APP_NAME` should align; expose ports via `APP_PORT` in `.env`.
- Scripts stay POSIX/bash, explicit flags, no silent `cd`, and match existing argument style (`./up.sh app1 app2`).

## Testing Guidelines
- Smoke-test new or changed apps with `./up.sh {app}` and reachability at `https://{app}.{DAPPS_DOMAIN}`.
- Run the compose `config` check before committing to catch syntax and missing vars.
- When adding dependencies, start the group together (`./up.sh app db`) and verify health/logs with `./logs.sh`.

## Commit & Pull Request Guidelines
- Use short, present-tense commits similar to history (`update readme`, `x-environment qbittorrentvpn`). Keep one logical change per commit.
- PR checklist: clear summary, affected apps/scripts, manual test notes (commands + outcome), and any new env vars with updates to the `*.example` files. Add screenshots/logs only when they clarify behavior or UI.

## Security & Configuration Tips
- Never commit secrets; rely on `.env` and per-app `.env` (git-ignored) and update the templates when adding keys.
- Keep Traefik in `DAPPS` and start it first; secure `apps-data/traefik/acme.json` (`chmod 600`).
- For database-backed apps, attach to `databases` network and reuse shared templates instead of embedding credentials. Prefer volumes under `../../apps-data/{APP_NAME}` and keep overrides in `config/` to avoid image rebuilds.
