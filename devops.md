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

Super simple - `fly launch` does most of the work:

### 1. Launch UAT

```bash
fly launch

# When prompted:
# - Name: code-my-spec-uat
# - Region: yyz (Toronto)
# - Postgres: Yes → name it code-my-spec-uat-db → pick smallest config
# - Machine: shared-cpu-1x, 256MB (minimal to start)
# - Deploy now: Yes
```

This creates the app, database, sets secrets, and deploys in one go.

### 2. Launch Prod

```bash
# Save fly.toml as fly.uat.toml first
mv fly.toml fly.uat.toml

fly launch

# When prompted:
# - Name: code-my-spec-prod
# - Region: yyz (Toronto)
# - Postgres: Yes → name it code-my-spec-prod-db → pick smallest config
# - Machine: shared-cpu-1x, 256MB (minimal to start)
# - Deploy now: Yes
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

## Custom Domain (codemyspec.com)

Once deployed, add your domain:

```bash
# Add domain to prod
fly certs add codemyspec.com -a code-my-spec-prod
fly certs add www.codemyspec.com -a code-my-spec-prod

# Get the DNS records to add
fly certs show codemyspec.com -a code-my-spec-prod
```

Then update your DNS:
- Add `A` and `AAAA` records pointing to Fly's IPs (shown in cert output)
- Add `CNAME` for www → codemyspec.com

Update prod secret:
```bash
fly secrets set PHX_HOST=codemyspec.com -a code-my-spec-prod
```

UAT can stay on `code-my-spec-uat.fly.dev`.

## Important Notes

- Each environment completely isolated
- Start minimal - 256MB RAM, 1 machine
- `fly launch` creates database and sets secrets automatically
- Scale only when metrics show you need to
- Check costs: `fly dashboard`
