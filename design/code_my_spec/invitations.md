# Invitations Context Summary

## Purpose
Manages the complete invitation workflow for adding users to accounts, including token generation, email delivery, expiration handling, and invitation acceptance.

## Core Responsibilities

### Invitation Lifecycle Management
- **Creation**: Generate secure invitation tokens with expiration dates
- **Delivery**: Trigger email notifications with invitation links
- **Tracking**: Monitor invitation status (pending, accepted, expired, cancelled)
- **Cleanup**: Handle expired invitations and cancellation requests

### User Onboarding Orchestration
- **Existing Users**: Direct addition to accounts when user already exists
- **New Users**: Coordinate user registration + account membership in single flow
- **Email Validation**: Ensure invited email matches registered email during acceptance

### Integration Points
- **Accounts Context**: Calls `Accounts.add_user_to_account/3` during acceptance
- **Users Context**: Calls `Users.register_user/1` for new user creation
- **UserSettings Context**: Retrieves active account ID from scope for invitation operations
- **Authorization Module**: Uses `Authorization.authorize/3` for permission checks
- **Email Service**: Sends invitation emails with secure token links

## Key Entities
- **Invitation**: Token, email, role, expiration, account association
- **Invitation States**: Derived from timestamps (pending → accepted/expired/cancelled)

## Business Logic Handled
- **Duplicate Prevention**: Don't invite users who already have account access
- **Token Security**: Cryptographically secure invitation tokens
- **Expiration Management**: Time-limited invitations (typically 7 days)
- **Role Preservation**: Invited role carries through to final membership

## Why Separate from Accounts?
- **Distinct Lifecycle**: Invitations have their own state machine and workflow
- **Email Integration**: Complex email templating and delivery logic
- **Error Handling**: Different failure modes (expired tokens, invalid emails, etc.)
- **Focused Responsibility**: Accounts manages membership, Invitations manages the process of getting there

## Public API

```elixir
# Invitation Management
@spec invite_user(scope :: Scope.t(), email :: String.t(), role :: account_role()) :: {:ok, Invitation.t()} | {:error, Ecto.Changeset.t() | :user_already_member | :user_limit_exceeded}
@spec accept_invitation(token :: String.t(), user_attrs :: map()) :: {:ok, {User.t(), Member.t()}} | {:error, :invalid_token | :expired_token | :email_mismatch | Ecto.Changeset.t()}
@spec list_pending_invitations(scope :: Scope.t()) :: [Invitation.t()]
@spec list_user_invitations(email :: String.t()) :: [Invitation.t()]
@spec cancel_invitation(scope :: Scope.t(), invitation_id :: integer()) :: {:ok, Invitation.t()} | {:error, :not_found | :not_authorized}
@spec get_invitation_by_token(token :: String.t()) :: Invitation.t() | nil
@spec cleanup_expired_invitations() :: :ok

# Custom Types
@type account_role :: :owner | :admin | :member
```

## State Management Strategy

### Persistence
- Ecto schema for invitations with secure token generation
- Automatic expiration handling through database queries
- Soft deletion for audit trail (status changes vs hard deletes)

### Consistency
- Transaction boundaries around invitation acceptance and user creation
- Email uniqueness validation within account context
- Role validation consistent with Accounts context

### Performance
- Indexed queries on token, email, and account_id fields
- Efficient expired invitation cleanup through scheduled jobs
- Preloading strategies for invitation-account relationships

## Component Diagram

```
Invitations (orchestrates invitation flow at a high level)
├── Invitation (token, email, role, status, expires_at, account_id, invited_by_id)
├── Invitations Repository
|   ├── Token Generation & Validation
|   ├── Expiration Management
|   └── Status Tracking
└── Mailer
    ├── Invitation Email Templates
    ├── Reminder Notifications
    └── Acceptance Confirmations
```

## Dependencies
- **Accounts Context**: User membership management and role validation
- **Users Context**: User registration and authentication
- **UserSettings Context**: Active account ID retrieval from scope
- **Authorization Module**: Permission checking via `Authorization.authorize/3`
- **Email Service**: Invitation delivery and notifications
- **Billing Context**: User limit validation (when implemented)

## Execution Flow

### Invitation Creation Flow
1. **Active Account Retrieval**: Extract active account ID from scope via UserSettings context
2. **Permission Check**: Use `Authorization.authorize(:manage_members, scope, account_id)` to verify admin/owner access
3. **Duplicate Check**: Ensure email doesn't already have account access
4. **Limit Check**: Verify account hasn't exceeded user limit (via Accounts context)
5. **Token Generation**: Create cryptographically secure invitation token
6. **Database Persistence**: Store invitation with expiration date
7. **Email Delivery**: Send invitation email with secure token link
8. **Audit Trail**: Log invitation creation for security tracking

### Invitation Acceptance Flow
1. **Token Validation**: Verify token exists and hasn't expired
2. **User Resolution**: Check if email belongs to existing user
3. **Email Validation**: For existing users, verify email matches registration
4. **Transaction Start**: Begin database transaction for atomicity
5. **User Creation**: If new user, call `Users.register_user/1`
6. **Account Addition**: Call `Accounts.add_user_to_account/3` with invitation role
7. **Status Update**: Mark invitation as accepted
8. **Transaction Commit**: Ensure all operations succeed together
9. **Notification**: Send welcome email to new account member

### Invitation Cleanup Flow
1. **Expired Detection**: Query for invitations past expiration date
2. **Status Update**: Mark expired invitations as expired
3. **Notification**: Optional notification to inviting user about expiration
4. **Audit Cleanup**: Remove sensitive data while preserving audit trail
5. **Statistics Update**: Update invitation success/failure metrics

### Permission Validation Flow
1. **Scope Extraction**: Get current user from scope
2. **Account Permission**: Use `Authorization.authorize(:manage_members, scope, account_id)` for admin/owner verification
3. **Invitation Ownership**: For cancellation, verify user created invitation or use `Authorization.authorize(:manage_members, scope, account_id)`
4. **Rate Limiting**: Prevent invitation spam through rate limiting
5. **Role Hierarchy**: Ensure invited role doesn't exceed inviter's role

## Error Handling Strategy

### Invitation Creation Errors
- **:user_already_member**: User already has access to account
- **:user_limit_exceeded**: Account has reached maximum user limit
- **:invalid_email**: Email format validation failed
- **:permission_denied**: Inviting user lacks required permissions

### Invitation Acceptance Errors
- **:invalid_token**: Token doesn't exist or malformed
- **:expired_token**: Token has passed expiration date
- **:email_mismatch**: Existing user's email doesn't match invitation
- **:account_limit_exceeded**: Account reached limit between invitation and acceptance

### Security Considerations
- **Token Entropy**: Use cryptographically secure random tokens
- **Expiration Enforcement**: Automatic cleanup of expired tokens
- **Rate Limiting**: Prevent invitation spam and abuse
- **Audit Trail**: Complete logging of invitation lifecycle events

This context acts as the "bridge" between having no relationship with an account and having full membership, handling all the complexity of that transition process while maintaining security and data integrity.