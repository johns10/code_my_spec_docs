# InviteForm Component

## Purpose
Inline form for sending new invitations with email and role selection. Displays as a plus button that toggles to reveal the form.

## Usage
```heex
<.live_component 
  module={InviteForm}
  id="invite-form"
  show={@show_invite_form}
  form={@invite_form}
  can_invite={can_manage_members?(@current_scope, @account)}
/>
```

## Props
- `show` - Boolean to control form visibility
- `form` - Phoenix form for validation and input binding
- `can_invite` - Boolean for permission check

## Template
### Collapsed State (Default)
- Plus button with "Invite Member" text
- Only shows if `can_invite` is true

### Expanded State (When `show` is true)
- Email input with validation
- Role selector dropdown (Member/Admin/Owner)
- Save and Cancel buttons
- Error display from form validation
- Form contained within a card or bordered section

## Validation
- Valid email format
- Role must be valid enum value (:member, :admin, :owner)
- Email not already a member (server-side validation)
- User has permission to invite with selected role

## Events (LiveComponent Messages)
- `{:show_invite_form, true/false}` - Toggle form visibility
- `{:send_invitation, %{email: email, role: role}}` - Submit invitation
- `{:cancel_invite_form}` - Cancel and hide form

## States
- `show: false` - Plus button visible
- `show: true` - Form expanded and visible
- Form validation states handled by Phoenix forms

## Integration
Used within the invitations tab of AccountLive.Show. Parent handles business logic:

```elixir
def handle_info({:show_invite_form, show}, socket) do
  {:noreply, assign(socket, :show_invite_form, show)}
end

def handle_info({:send_invitation, params}, socket) do
  # Create invitation logic
end
```