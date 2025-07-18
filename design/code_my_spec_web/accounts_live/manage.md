# Account Manage LiveView

## Purpose
Account settings and administration form for updating account details and deletion.

## Route
`/accounts/:id/manage`

## Context Access
- `CodeMySpec.Accounts.get_account(scope, id)` - Get account details
- `CodeMySpec.Accounts.update_account(scope, account, attrs)` - Update account
- `CodeMySpec.Accounts.delete_account(scope, account)` - Delete account

## LiveView Structure

### Mount
- Get account ID from params
- Load account details and verify access
- Subscribe to account updates
- Initialize account form changeset

### Events
- `validate-account` - Validate account form changes
- `update-account` - User updates account settings
  - Validate account details
  - Call `update_account/3`
  - Show success message
- `delete-account` - User deletes account (owners only)
  - Show confirmation dialog
  - Call `delete_account/2`
  - Redirect to accounts index

### Template
- `AccountLive.Components.Navigation` component with active tab `:manage`
- Account settings form with name and description fields
- Update button
- Danger zone with delete account button (owners only)
- Permission-based action visibility

## Data Flow
1. User navigates to `/accounts/:id/manage`
2. LiveView loads account and verifies access
3. User updates account settings via form
4. Real-time updates for account changes

## Security
- Validate account access on mount
- Check permissions for update actions
- Owners only for account deletion
- Confirm destructive actions

## Real-time Updates
- Subscribe to account PubSub events
- Update account details when changed externally