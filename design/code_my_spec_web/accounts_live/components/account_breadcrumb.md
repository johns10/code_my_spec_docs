## AccountBreadcrumb
**Purpose**: Breadcrumb link showing current account with click to switch

**Usage**: `<.account_breadcrumb scope={@scope} />`

**Props**:
- `scope` - Current user scope with active account

**Template**:
- Shows current account name (or "Select Account" if none)
- Links to `/accounts/picker`
- Breadcrumb styling