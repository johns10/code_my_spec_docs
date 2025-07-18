# Account Members LiveView

## Purpose
Member management for accounts including role updates and member removal.

## Route
`/accounts/:id/members`

## Context Access
- `CodeMySpec.Accounts.get_account(scope, id)` - Get account details
- `CodeMySpec.Accounts.list_account_members(scope, account_id)` - Get members
- `CodeMySpec.Accounts.update_user_role(scope, user_id, account_id, role)` - Update role
- `CodeMySpec.Accounts.remove_user_from_account(scope, user_id, account_id)` - Remove member

## LiveView Structure

### Mount
- Get account ID from params
- Load account details and verify access
- Load account members list
- Subscribe to account and member updates

### Events
- `remove-member` - Remove user from account
  - Call `remove_user_from_account/3`
  - Update members list
  - Show success message
- `update-member-role` - Change user's role
  - Call `update_user_role/4`
  - Update members list
  - Show success message

### Template
- `AccountLive.Components.Navigation` component with active tab `:members`
- Members table showing:
  - User name and email
  - Current role
  - Join date
  - Role update dropdown (admins+)
  - Remove button (admins+)
- Permission-based action visibility
- Empty state when no members

## Data Flow
1. User navigates to `/accounts/:id/members`
2. LiveView loads account and members list
3. User can update roles or remove members
4. Real-time updates for member changes

## Security
- Validate account access on mount
- Check permissions for each action
- Admins+ only for member management
- Cannot remove self or demote own role

## Real-time Updates
- Subscribe to account and member PubSub events
- Update member list when users added/removed
- Show live role changes