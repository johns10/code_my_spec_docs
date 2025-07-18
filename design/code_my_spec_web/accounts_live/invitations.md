# Account Invitations LiveView

## Purpose
Invitation management for accounts including sending new invitations and managing pending ones.

## Route
`/accounts/:id/invitations`

## Context Access
- `CodeMySpec.Accounts.get_account(scope, id)` - Get account details
- `CodeMySpec.Invitations.list_pending_invitations(scope)` - Get pending invitations
- `CodeMySpec.Invitations.invite_user(scope, account_id, email, role)` - Send invitation
- `CodeMySpec.Invitations.cancel_invitation(scope, invitation_id)` - Cancel invitation

## LiveView Structure

### Mount
- Get account ID from params
- Load account details and verify access
- Load pending invitations list
- Subscribe to invitation updates
- Initialize invitation form changeset

### Events
- `show-invite-form` - Toggle invitation form visibility
- `cancel-invite-form` - Hide invitation form
- `validate-invitation` - Validate invitation form changes
- `send-invitation` - Send new invitation
  - Validate email and role
  - Call `invite_user/4`
  - Update pending invitations list
  - Show success message
- `cancel-invitation` - Cancel pending invitation
  - Call `cancel_invitation/2`
  - Update pending invitations list
  - Show success message

### Template
- `AccountLive.Components.Navigation` component with active tab `:invitations`
- Invitation form with:
  - Email input field
  - Role selection dropdown
  - Send button
  - Cancel button
- Pending invitations table showing:
  - Email address
  - Role
  - Sent date
  - Status
  - Cancel button (admins+)
- Permission-based action visibility
- Empty state when no pending invitations

## Data Flow
1. User navigates to `/accounts/:id/invitations`
2. LiveView loads account and pending invitations
3. User can send new invitations or cancel pending ones
4. Real-time updates for invitation changes

## Security
- Validate account access on mount
- Check permissions for each action
- Admins+ only for invitation management
- Validate email format and role selection

## Real-time Updates
- Subscribe to invitation PubSub events
- Update invitation list when invitations sent/cancelled
- Show live status changes