# Account Picker LiveView

## Purpose
Allow users to select their active account from available accounts (personal + team accounts they're members of).

## Route
`/accounts/picker`

## Context Access
- `CodeMySpec.Accounts.list_accounts(scope)` - Get all accounts user has access to
- `CodeMySpec.UserPreferences.update_user_preference(scope, %{active_account_id: id})` - Set active account

## LiveView Structure

### Mount
- Get current user scope
- Load all available accounts
- Show current active account (if any)

### Events
- `account-selected` - User clicks on an account
  - Update user preferences with new active_account_id
  - Redirect to intended destination or root

### Template
- DaisyUI menu component with account list
- Each menu item shows: account name, type (personal/team), user's role
- Active account highlighted using menu's active state
- Click menu item to select

## Data Flow
1. User navigates to `/accounts/picker`
2. LiveView loads user's accessible accounts
3. User clicks desired account
4. Preference updated in database
5. User redirected with new scope

## Security
- Only show accounts user has access to via `MembersRepository.list_user_accounts/1`
- Validate account access before setting preference