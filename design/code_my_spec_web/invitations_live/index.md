# Invitations Index LiveView

## Purpose
Manage invitations for the current active account - send new invitations, view pending ones, and cancel existing invitations.

## Route
`/invitations`

## Context Access
- `CodeMySpec.Invitations.list_pending_invitations(scope)` - Get pending invitations for active account
- `CodeMySpec.Invitations.invite_user(scope, email, role)` - Send new invitation
- `CodeMySpec.Invitations.cancel_invitation(scope, invitation_id)` - Cancel invitation

## LiveView Structure

### Mount
- Get current user scope
- Load pending invitations for active account
- Subscribe to invitation updates via PubSub

### Events
- `send-invitation` - User submits invitation form
  - Validate email and role
  - Call `invite_user/3`
  - Show success/error message
  - Reset form on success
- `cancel-invitation` - User cancels pending invitation
  - Call `cancel_invitation/2`
  - Update invitation list

### Template
- Page header with current account context
- Invitation form (email input + role selector)
- DaisyUI table showing pending invitations:
  - Email, Role, Invited By, Date Sent, Actions (Cancel)
- Empty state when no pending invitations

## Data Flow
1. User navigates to `/invitations` 
2. LiveView loads pending invitations for active account
3. User fills invitation form and submits
4. Email sent, invitation added to pending list
5. User can cancel invitations from table

## Security
- Only show/manage invitations for user's active account
- Validate `manage_members` permission before sending/canceling
- Handle authorization errors gracefully

## Real-time Updates
- Subscribe to invitation PubSub events
- Update invitation list when invitations created/cancelled
- Show live status updates