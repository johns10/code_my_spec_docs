# Account Navigation Component

## Purpose
Shared tabbed navigation component for account management LiveViews to maintain consistent UI while having separate routes.

## Component Structure
- `AccountLive.Components.Navigation`
- Takes current account and active tab as props
- Renders tab navigation with proper route links
- Highlights active tab based on current path

## Tabs
- **Manage** - `/accounts/:id/manage` - Account settings and details
- **Members** - `/accounts/:id/members` - Member management
- **Invitations** - `/accounts/:id/invitations` - Invitation management

## Template
- Account header with name and subtitle
- Tab navigation using proper `<.link>` components for routing
- Active tab styling based on current path
- Consistent layout wrapper for all account pages

## Usage
Each account LiveView will:
1. Include the navigation component in their template
2. Pass the current account and active tab identifier
3. Be wrapped in consistent layout structure
4. Handle their own specific functionality

## Security
- Tab visibility based on user permissions
- Hide invitation tab if user cannot manage members
- Consistent permission checks across all tabs