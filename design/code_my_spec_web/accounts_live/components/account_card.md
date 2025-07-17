## AccountCard
**Purpose**: Display account info in grid/list layouts

**Usage**: `<.account_card account={account} current_user={@current_user} />`

**Props**:
- `account` - Account struct
- `current_user` - User struct for role display
- `active` - Boolean for highlighting active account

**Template**:
- DaisyUI card with account name
- Shows account type (Personal/Team)
- User's role in account
- Member count for team accounts
- Click action to switch accounts