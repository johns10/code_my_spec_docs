# Formal DevOps: Hetzner + Cloudflare + AWS

## Problem

Deployment is ad-hoc — a single rsync + docker compose script with no environment separation, no UAT, hardcoded IPs everywhere, secrets managed by hand, and no repeatable infrastructure provisioning. We need formalized environments, scripted deployments, and proper secrets management.

## Current State

What we already have working:

- **Hetzner cax11** (ARM, 4GB) at `46.225.105.88` running Docker Compose (Phoenix + Postgres + Caddy)
- **Cloudflare** DNS for `fuellytics.app` (A record → Hetzner) + dev tunnel to `dev.fuellytics.app`
- **AWS** account `889081505590` with ExAws/S3 wired up in code (`Fuellytics.Storage.S3`, bucket `fuellytics-uploads`)
- **Single deploy script** (`.code_my_spec/devops/deploy`) that rsyncs and rebuilds
- **Caddy** auto-TLS via Let's Encrypt
- **Dotenvy** loading env files from `envs/` locally, `/opt/fuellytics/.env` on server

## Target Architecture

### Environments

| Environment | Domain | Purpose | Infrastructure |
|-------------|--------|---------|----------------|
| **dev** | `dev.fuellytics.app` | Local dev exposed via Cloudflare Tunnel | Developer laptop |
| **uat** | `uat.fuellytics.app` | Pre-production testing, QA, demos | Hetzner (same or separate server) |
| **prod** | `fuellytics.app` | Production | Hetzner (current server) |

### DNS (Cloudflare)

- `fuellytics.app` → Hetzner prod IP (A record, proxied)
- `uat.fuellytics.app` → Hetzner prod IP (A record, proxied) — separate Docker Compose stack on different ports, Caddy routes by hostname
- `dev.fuellytics.app` → Cloudflare Tunnel (already working)

### AWS Services

- **S3**: `fuellytics-uploads` bucket for photo storage (prod), `fuellytics-uploads-uat` for UAT
- **IAM**: Dedicated `fuellytics-deploy` user with scoped S3 permissions (not root)
- **Credentials**: IAM access keys stored as server env vars, ExAws credential chain picks them up

## Implementation Plan

### 1. AWS Setup

- [ ] Create S3 buckets: `fuellytics-uploads` (prod), `fuellytics-uploads-uat` (UAT)
- [ ] Create IAM user `fuellytics-app` with policy scoped to those buckets
- [ ] Generate access keys, add `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` to server env files
- [ ] Set bucket CORS policy (needed for direct upload if we ever do that)
- [ ] Script: `scripts/aws-setup.sh` — creates buckets, IAM user, attaches policy

### 2. Environment Separation

- [ ] Parameterize `docker-compose.yml` with `COMPOSE_PROJECT_NAME` so uat and prod can coexist on same host
- [ ] Create `docker-compose.uat.yml` override (different ports, db volume, project name)
- [ ] Update `Caddyfile` to route both `fuellytics.app` and `uat.fuellytics.app` to their respective app containers
- [ ] Create `/opt/fuellytics/uat.env` with UAT-specific values (separate DB, separate S3 bucket, `PHX_HOST=uat.fuellytics.app`)
- [ ] Add `S3_BUCKET` to docker-compose env passthrough (already in runtime.exs)

### 3. Deployment Scripts

All scripts live in `scripts/` at project root.

```
scripts/
  deploy.sh          # Deploy to a target environment
  setup-server.sh    # First-time server provisioning
  secrets.sh         # Manage secrets on the server
  rollback.sh        # Roll back to previous Docker image
  db-backup.sh       # Backup Postgres from a target env
  db-restore.sh      # Restore a Postgres backup
  logs.sh            # Tail logs from a target env
  ssh.sh             # SSH into a target env
  aws-setup.sh       # One-time AWS resource provisioning
```

#### `scripts/deploy.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

ENV="${1:?Usage: deploy.sh <prod|uat>}"
SERVER="root@46.225.105.88"

case "$ENV" in
  prod)
    APP_DIR="/opt/fuellytics/app"
    ENV_FILE="/opt/fuellytics/prod.env"
    COMPOSE_PROJECT="fuellytics-prod"
    ;;
  uat)
    APP_DIR="/opt/fuellytics/uat"
    ENV_FILE="/opt/fuellytics/uat.env"
    COMPOSE_PROJECT="fuellytics-uat"
    ;;
  *) echo "Unknown env: $ENV" && exit 1 ;;
esac

echo "==> Deploying $ENV..."

echo "==> Syncing code..."
rsync -az --delete \
  --exclude='.git' --exclude='_build' --exclude='deps' \
  --exclude='assets/node_modules' --exclude='.code_my_spec' \
  --exclude='test' --exclude='envs' \
  ./ "$SERVER:$APP_DIR/"

echo "==> Building and restarting..."
ssh "$SERVER" "cd $APP_DIR && COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT docker compose --env-file $ENV_FILE up -d --build"

echo "==> Running migrations..."
ssh "$SERVER" "cd $APP_DIR && COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT docker compose --env-file $ENV_FILE exec app /app/bin/migrate"

echo "==> Deployed $ENV! ✓"
```

#### `scripts/secrets.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

ENV="${1:?Usage: secrets.sh <prod|uat> [get|set|list] [KEY] [VALUE]}"
ACTION="${2:-list}"
KEY="${3:-}"
VALUE="${4:-}"
SERVER="root@46.225.105.88"

case "$ENV" in
  prod) ENV_FILE="/opt/fuellytics/prod.env" ;;
  uat)  ENV_FILE="/opt/fuellytics/uat.env" ;;
  *)    echo "Unknown env: $ENV" && exit 1 ;;
esac

case "$ACTION" in
  list)
    ssh "$SERVER" "cat $ENV_FILE | grep -v '^#' | sed 's/=.*/=***/' | sort"
    ;;
  get)
    ssh "$SERVER" "grep '^${KEY}=' $ENV_FILE | cut -d= -f2-"
    ;;
  set)
    [ -z "$KEY" ] || [ -z "$VALUE" ] && echo "Usage: secrets.sh <env> set KEY VALUE" && exit 1
    ssh "$SERVER" "grep -q '^${KEY}=' $ENV_FILE && sed -i 's|^${KEY}=.*|${KEY}=${VALUE}|' $ENV_FILE || echo '${KEY}=${VALUE}' >> $ENV_FILE"
    echo "Set $KEY in $ENV. Redeploy to apply."
    ;;
  *)
    echo "Unknown action: $ACTION"
    exit 1
    ;;
esac
```

#### `scripts/setup-server.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

SERVER="root@46.225.105.88"

echo "==> Installing Docker..."
ssh "$SERVER" "apt-get update && apt-get install -y docker.io docker-compose-plugin"

echo "==> Creating directory structure..."
ssh "$SERVER" "mkdir -p /opt/fuellytics/{app,uat}"

echo "==> Generating secrets..."
SECRET_KEY_PROD=$(mix phx.gen.secret)
SECRET_KEY_UAT=$(mix phx.gen.secret)
PG_PASS_PROD=$(openssl rand -hex 16)
PG_PASS_UAT=$(openssl rand -hex 16)

echo "==> Writing prod.env template..."
ssh "$SERVER" "cat > /opt/fuellytics/prod.env << 'ENVEOF'
POSTGRES_PASSWORD=$PG_PASS_PROD
SECRET_KEY_BASE=$SECRET_KEY_PROD
PHX_HOST=fuellytics.app
DATABASE_URL=ecto://fuellytics:$PG_PASS_PROD@db/fuellytics_prod
S3_BUCKET=fuellytics-uploads
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_MESSAGING_SERVICE_SID=
TWILIO_FROM_NUMBER=
TWILIO_STATUS_CALLBACK_URL=
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
ANTHROPIC_API_KEY=
ENVEOF"

echo "==> Writing uat.env template..."
ssh "$SERVER" "cat > /opt/fuellytics/uat.env << 'ENVEOF'
POSTGRES_PASSWORD=$PG_PASS_UAT
SECRET_KEY_BASE=$SECRET_KEY_UAT
PHX_HOST=uat.fuellytics.app
DATABASE_URL=ecto://fuellytics:$PG_PASS_UAT@db/fuellytics_uat
S3_BUCKET=fuellytics-uploads-uat
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_MESSAGING_SERVICE_SID=
TWILIO_FROM_NUMBER=
TWILIO_STATUS_CALLBACK_URL=
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
ANTHROPIC_API_KEY=
ENVEOF"

echo "==> Server provisioned. Fill in API keys with: scripts/secrets.sh <prod|uat> set KEY VALUE"
```

### 4. Caddyfile (Multi-Environment)

```
fuellytics.app {
    reverse_proxy fuellytics-prod-app-1:4000
}

uat.fuellytics.app {
    reverse_proxy fuellytics-uat-app-1:4000
}
```

Caddy runs as a shared service (not per-stack). Both stacks join a shared Docker network.

### 5. Cloudflare DNS Records

| Type | Name | Content | Proxy |
|------|------|---------|-------|
| A | `fuellytics.app` | `46.225.105.88` | Yes |
| A | `uat` | `46.225.105.88` | Yes |
| CNAME | `dev` | Cloudflare Tunnel | Yes |

### 6. Rename Current .env

Rename `/opt/fuellytics/.env` → `/opt/fuellytics/prod.env` and update the deploy script accordingly. Keeps things explicit.

## Migration Path

1. Create `scripts/` directory with all scripts
2. Set up AWS (S3 buckets + IAM user)
3. Add `uat.fuellytics.app` DNS record in Cloudflare
4. Rename `.env` → `prod.env` on server
5. Deploy UAT stack alongside prod on same Hetzner box
6. Update Caddy to route both domains
7. Remove the old `.code_my_spec/devops/deploy` script in favor of `scripts/deploy.sh`
8. Revert `dev_routes: true` in prod.exs (keep it only for UAT)

## Out of Scope (Future)

- CI/CD pipeline (GitHub Actions) — add once workflow is stable
- Container registry (build once, push image, pull on server instead of building on server)
- Separate Hetzner server for UAT (current box has headroom for both)
- Monitoring / alerting (uptime checks, error tracking)
- Database replication / managed Postgres
- Blue-green or rolling deployments
