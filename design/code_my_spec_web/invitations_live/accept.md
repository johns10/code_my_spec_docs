# Invitation Accept LiveView

## Purpose
Public page where users accept invitations via token. Handles both new user registration and existing user acceptance.

## Route
`/invitations/accept/:token`

## Context Access
- `CodeMySpec.Invitations.get_invitation_by_token(token)` - Get invitation details
- `CodeMySpec.Invitations.accept_invitation(token, user_attrs)` - Accept invitation

## LiveView Structure

### Mount
- Extract token from params
- Load invitation details
- Check if invitation is valid (not expired/cancelled)
- Show invitation info (account name, inviter, role)

### Events
- `accept-invitation` - User submits acceptance form
  - For new users: validate registration form
  - For existing users: just confirm acceptance
  - Call `accept_invitation/2`
  - Redirect to login or account dashboard

### Template
- Invitation details card showing:
  - Account name being joined
  - Role being granted
  - Who sent the invitation
- Two paths based on user status:
  - **New users**: Registration form (name, email pre-filled, password)
  - **Existing users**: Simple "Accept Invitation" button
- Error states for invalid/expired tokens

## Data Flow
1. User clicks invitation link with token
2. LiveView loads invitation details
3. If valid, show acceptance form
4. User accepts (with registration if new)
5. User added to account, redirected to dashboard

## Security
- Validate token before showing any invitation details
- Check expiration and cancellation status
- Email must match invitation for existing users
- Rate limiting on acceptance attempts

## Error Handling
- Invalid token: Show friendly error message
- Expired invitation: Show expired state with contact info
- Email mismatch: Clear error for existing users
- Already accepted: Redirect to login