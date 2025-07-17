# MembersList Component

## Purpose
Display account members in a table with role management actions

## Usage
```heex
<.members_list 
  members={@members} 
  current_user={@current_user}
  can_manage={@can_manage_members}
/>
```

## Props
- `members` - List of member structs with user info
- `current_user` - Current user struct
- `can_manage` - Boolean for showing management actions

## Template
- DaisyUI table with columns:
  - Name/Email
  - Role (Owner/Admin/Member)
  - Joined Date
  - Actions (if can_manage)
- Role selector dropdown for admins
- Remove member button (if not self)
- Empty state when no members

## Events
- `update-role` - Change member role
- `remove-member` - Remove member from account