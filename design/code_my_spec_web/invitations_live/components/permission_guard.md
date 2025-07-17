# PermissionGuard Component

## Purpose
Conditionally render content based on user permissions

## Usage
```heex
<.permission_guard 
  permission={:manage_members}
  scope={@scope}
  resource_id={@account.id}
>
  <button>Manage Members</button>
</.permission_guard>
```

## Props
- `permission` - Permission atom (:manage_members, :manage_account, etc.)
- `scope` - Current user scope
- `resource_id` - Account ID or other resource identifier
- `fallback` - Optional content to show when permission denied

## Template
- Renders inner content if permission granted
- Renders fallback content if permission denied
- Renders nothing if no fallback and permission denied

## Logic
- Uses `CodeMySpec.Authorization.authorize/3`
- Handles authorization errors gracefully
- Can be nested for complex permission logic

## Examples
```heex
<!-- Simple hide/show -->
<.permission_guard permission={:manage_account} scope={@scope} resource_id={@account.id}>
  <.button>Delete Account</.button>
</.permission_guard>

<!-- With fallback -->
<.permission_guard permission={:read_account} scope={@scope} resource_id={@account.id}>
  <p>Account details here</p>
  <:fallback>
    <p>Access denied</p>
  </:fallback>
</.permission_guard>
```