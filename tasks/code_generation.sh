#!/bin/bash
# Code generation script — produced by CodeMySpec code_generation task
# Re-run on a fresh Phoenix project to reproduce this scaffold.

set -e

# Authentication (LiveView): registration, login, session management.
# Produces lib/code_my_spec/users/{user,scope,...}.ex and the
# UserSessionController/UserAuth plug.
mix phx.gen.auth Users User users --live

# Multi-tenant accounts with members and invitations.
# Produces lib/code_my_spec/accounts/{account,member,invitation}.ex
# and account-scoped Scope augmentation.
mix cms_gen.accounts

# OAuth integration scaffolding with encrypted token storage.
# Produces lib/code_my_spec/integrations/{integration,integration_repository}.ex
# plus Cloak vault wiring for encrypted tokens.
mix cms_gen.integrations

# Per-provider OAuth modules under lib/code_my_spec/integrations/providers/.
mix cms_gen.integration_provider GitHub github
mix cms_gen.integration_provider Google google
