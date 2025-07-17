# Accounts Index LiveView

## Purpose
Show all accounts the user has access to with quick actions. Main dashboard for account management.

## Route
`/accounts`

## Context Access
- `CodeMySpec.Accounts.list_accounts(scope)` - Get all user's accounts
- `CodeMySpec.Accounts.get_personal_account(scope)` - Get personal account
- `CodeMySpec.Accounts.create_team_account(scope, attrs)` - Create new team account

## LiveView Structure

### Mount
- Get current user scope
- Load all accessible accounts
- Subscribe to account updates via PubSub

### Events
- `create-team-account` - User submits new team form
  - Validate account name
  - Call `create_team_account/2`
  - Add to accounts list
- `show-create-form` - Toggle create account form visibility

### Template
- Page header with "Your Accounts"
- Current active account highlighted at top
- DaisyUI cards grid showing:
  - **Personal Account**: Always present, special styling
  - **Team Accounts**: Name, role, member count, last activity
- "Create Team Account" button/form
- Quick actions on each card:
  - Manage (if owner/admin) → links to account settings
  - View members → links to members page

## Data Flow
1. User navigates to `/accounts`
2. LiveView loads all accessible accounts
3. User can switch accounts, create new ones, or manage existing
4. Real-time updates when accounts are created/modified

## Security
- Only show accounts user has access to
- Validate permissions before showing management actions
- Handle authorization gracefully

## Real-time Updates
- Subscribe to account PubSub events
- Update account list when accounts created/updated
- Show live member count changes