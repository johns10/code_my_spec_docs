# DevOps Plan - Fly.io Deployment

## Overview

Minimal deployment using Fly.io with two environments:
- **UAT** - User acceptance testing
- **Prod** - Production (start minimal, scale later)

Region: `yyz` (Toronto)

## Architecture

### Apps
- `code-my-spec-uat` - UAT environment
- `code-my-spec-prod` - Production environment

### Databases
- Created automatically during launch
- Postgres attached to each app
- Completely isolated per environment

## Initial Setup

### 1. Launch UAT

**Important:** If you change the app name during launch, you must create the database manually.

```bash
# Launch the app (accept defaults, but change name when prompted)
fly launch

# When prompted:
# - Name: code-my-spec-uat
# - Region: yyz (Toronto)
# - Postgres: No (we'll create manually)
# - Machine: shared-cpu-1x, 256MB (minimal to start)
# - Deploy now: No (we need to attach DB first)

# Create database manually
fly postgres create --name code-my-spec-uat-db --region yyz

# Pick smallest config when prompted

# Attach database to app (sets DATABASE_URL automatically)
fly postgres attach code-my-spec-uat-db -a code-my-spec-uat

# Now deploy
fly deploy -a code-my-spec-uat
```

Save the generated `fly.toml` as `fly.uat.toml`.

### 2. Launch Prod

```bash
# Launch the app
fly launch

# When prompted:
# - Name: code-my-spec-prod
# - Region: yyz (Toronto)
# - Postgres: No (we'll create manually)
# - Machine: shared-cpu-1x, 256MB (minimal to start)
# - Deploy now: No

# Create database manually
fly postgres create --name code-my-spec-prod-db --region yyz

# Attach database
fly postgres attach code-my-spec-prod-db -a code-my-spec-prod

# Deploy
fly deploy -a code-my-spec-prod
```

Save as `fly.prod.toml`.

### 3. Add Additional Secrets (if needed)

`fly launch` sets `SECRET_KEY_BASE` and `DATABASE_URL` automatically.

Add anything else you need:

```bash
# UAT - only if you need CLOAK_KEY or API keys
fly secrets set CLOAK_KEY=$(mix phx.gen.secret) -a code-my-spec-uat

# Prod - same secrets, different values
fly secrets set CLOAK_KEY=$(mix phx.gen.secret) -a code-my-spec-prod
```

That's it. You're deployed.

## Daily Operations

### Deploy
```bash
# UAT
fly deploy -a code-my-spec-uat --config fly.uat.toml

# Prod
fly deploy -a code-my-spec-prod --config fly.prod.toml
```

### Logs
```bash
fly logs -a code-my-spec-uat    # UAT
fly logs -a code-my-spec-prod   # Prod
```

### Status
```bash
fly status -a code-my-spec-uat
fly status -a code-my-spec-prod
```

## Scaling (When You Need It)

You're starting with **zero users** - don't scale until you need to.

**Initial setup:**
- 1 machine per environment
- `shared-cpu-1x`, 256MB RAM
- Postgres: smallest config

**When to scale:**
- App is slow → add RAM first: `fly scale vm shared-cpu-1x --memory 512 -a code-my-spec-prod`
- Need redundancy → add machines: `fly scale count 2 -a code-my-spec-prod`
- Database slow → bigger CPU: `fly postgres update --vm-size dedicated-cpu-1x -a code-my-spec-prod-db`

Monitor with `fly dashboard -a code-my-spec-prod`.

## Workflow

1. Develop locally
2. Deploy to UAT → `fly deploy -a code-my-spec-uat`
3. Test in UAT
4. Deploy to Prod → `fly deploy -a code-my-spec-prod`

## Quick Reference

```bash
# Deploy
fly deploy -a code-my-spec-prod --config fly.prod.toml

# Logs
fly logs -a code-my-spec-prod

# Status
fly status -a code-my-spec-prod

# Add a secret
fly secrets set API_KEY=value -a code-my-spec-prod

# List secrets (names only)
fly secrets list -a code-my-spec-prod

# SSH into machine
fly ssh console -a code-my-spec-prod

# Rollback
fly releases rollback -a code-my-spec-prod

# Connect to database
fly postgres connect -a code-my-spec-prod-db
```

## Custom Domains (codemyspec.com)

### 1. Get IP addresses

```bash
# Prod IPs
fly ips list -a code-my-spec-prod

# UAT IPs
fly ips list -a code-my-spec-uat
```

You'll get IPv4 and IPv6 addresses - write them down.

### 2. Update DNS

In your DNS provider (Cloudflare, etc.):

**Prod (codemyspec.com):**
- `A` record: `codemyspec.com` → prod IPv4 address
- `AAAA` record: `codemyspec.com` → prod IPv6 address
- `CNAME` record: `www.codemyspec.com` → `codemyspec.com`

**UAT (uat.codemyspec.com):**
- `A` record: `uat.codemyspec.com` → UAT IPv4 address
- `AAAA` record: `uat.codemyspec.com` → UAT IPv6 address

**If using Cloudflare:** Set SSL mode to "Full" or "Full (Strict)"

### 3. Add certificates

After DNS is set up (wait a few minutes for propagation):

```bash
# Prod
fly certs add codemyspec.com -a code-my-spec-prod
fly certs add www.codemyspec.com -a code-my-spec-prod

# UAT
fly certs add uat.codemyspec.com -a code-my-spec-uat

# Check certificate status
fly certs show codemyspec.com -a code-my-spec-prod
fly certs show uat.codemyspec.com -a code-my-spec-uat
```

### 4. Update PHX_HOST secrets

```bash
fly secrets set PHX_HOST=codemyspec.com -a code-my-spec-prod
fly secrets set PHX_HOST=uat.codemyspec.com -a code-my-spec-uat
```

## Connecting Livebook to Production

You can connect Livebook running on your local machine to your production Fly.io app for debugging and exploration.

#### Get the full node name:

The easiest way is to SSH into the machine and check:
```bash
fly ssh console -a code-my-spec-prod -C "/app/bin/code_my_spec remote"
```

Look at the IEx prompt - it shows the full node name:
```
iex(code-my-spec-prod-01KAFFHA457JZ6VD2Y3H5C5YKS@fdaa:0:e4ed:a7b:175:814b:1e52:2)1>
```

The node name format is: `{APP_NAME}-{IMAGE_REF}@{PRIVATE_IP}`

**Important:** This node name changes with each deployment because `IMAGE_REF` is the deployment ID.

#### Get the cookie:

The cookie is stored in `envs/prod.env` as `RELEASE_COOKIE`:
```bash
grep RELEASE_COOKIE envs/prod.env
```

## Important Notes

- Each environment completely isolated
- Start minimal - 256MB RAM, 1 machine
- `fly launch` creates database and sets secrets automatically
- Scale only when metrics show you need to
- Check costs: `fly dashboard`
