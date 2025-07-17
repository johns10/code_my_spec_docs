# Account Show/Settings LiveView

## Purpose
Detailed view and management of a specific account. Settings, member management, and account administration.

## Route
`/accounts/:id`

## Context Access
- `CodeMySpec.Accounts.get_account!(scope, id)` - Get account details
- `CodeMySpec.Accounts.update_account(scope, account, attrs)` - Update account
- `CodeMySpec.Accounts.delete_account(scope, account)` - Delete account
- `CodeMySpec.Accounts.list_account_members(scope, account_id)` - Get members

## LiveView Structure

### Mount
- Get account ID from params
- Load account details and verify access
- Load account members
- Subscribe to account and member updates

### Events
- `update-account` - User updates account settings
  - Validate account details
  - Call `update_account/3`
  - Show success message
- `delete-account` - User deletes account (owners only)
  - Show confirmation modal
  - Call `delete_account/2`
  - Redirect to accounts index
- `remove-member` - Remove user from account
  - Call `remove_user_from_account/3`
  - Update members list
- `update-member-role` - Change user's role
  - Call `update_user_role/4`
  - Update members list

### Template
- Account header with name, type, creation date
- Tabbed interface:
  - **Settings**: Account name, description, danger zone
  - **Members**: Members table with roles and actions
  - **Invitations**: Link to invitations management
- Permission-based action visibility
- Confirmation modals for destructive actions

## Data Flow
1. User navigates to `/accounts/:id`
2. LiveView loads account and verifies access
3. User can update settings, manage members
4. Real-time updates for member changes

## Security
- Validate account access on mount
- Check permissions for each action
- Owners only for account deletion
- Admins+ for member management

## Real-time Updates
- Subscribe to account and member PubSub events
- Update member list when users added/removed
- Show live role changes