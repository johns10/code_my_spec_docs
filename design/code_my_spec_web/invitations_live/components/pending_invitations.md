# PendingInvitations Component

## Purpose
Display list of pending invitations with management actions for the invitations tab in account show page

## Usage
```heex
<.live_component 
  module={PendingInvitations}
  id="pending-invitations"
  invitations={@pending_invitations}
  can_manage={can_manage_members?(@current_scope, @account)}
/>
```

## Props
- `invitations` - List of pending invitation structs
- `can_manage` - Boolean for showing cancel actions

## Template
- DaisyUI table with columns:
  - Email
  - Role  
  - Invited By
  - Date Sent
  - Expires At
  - Actions (Cancel if can_manage)
- Empty state when no pending invitations
- Expired invitations highlighted with warning styling
- Responsive design with overflow handling

## Events (LiveComponent Messages)
- `{:cancel_invitation, invitation_id}` - Sends message to parent to cancel invitation
- `{:resend_invitation, invitation_id}` - Sends message to parent to resend invitation (future)

## States
- Pending (normal styling)
- Expired (warning styling, disabled actions)
- Cancelled (filtered out from display)

## Integration
Used within the invitations tab of AccountLive.Show. Parent handles business logic via message handlers:

```elixir
def handle_info({:cancel_invitation, invitation_id}, socket) do
  # Business logic in parent
end
```