# Invitation Schema Design

## Overview
The Invitation schema represents the data structure for managing invitation tokens, their associated metadata, and lifecycle tracking. It serves as the bridge between invitation creation and user onboarding.

## Core Entity Structure

### Primary Fields
- **token**: Cryptographically secure 32-character string for invitation access
- **email**: Email address of the person being invited
- **role**: The account role they'll receive upon acceptance (owner, admin, member)
- **status**: Current invitation state (pending, accepted, expired, cancelled)
- **expires_at**: Timestamp when the invitation becomes invalid
- **accepted_at**: Timestamp when invitation was accepted (nil if pending)

### Relationships
- **account_id**: References the account they're being invited to join
- **invited_by_id**: References the user who created the invitation

### Audit Fields
- **inserted_at**: When the invitation was created
- **updated_at**: When the invitation was last modified

## Schema Implementation

```elixir
defmodule CodeMySpec.Invitations.Invitation do
  use Ecto.Schema
  import Ecto.Changeset
  
  alias CodeMySpec.Accounts.Account
  alias CodeMySpec.Users.User
  
  @type t :: %__MODULE__{
    id: integer(),
    token: String.t(),
    email: String.t(),
    role: account_role(),
    status: invitation_status(),
    expires_at: DateTime.t(),
    accepted_at: DateTime.t() | nil,
    account_id: integer(),
    invited_by_id: integer(),
    inserted_at: DateTime.t(),
    updated_at: DateTime.t()
  }
  
  @type invitation_status :: :pending | :accepted | :expired | :cancelled
  @type account_role :: :owner | :admin | :member
  
  schema "invitations" do
    field :token, :string
    field :email, :string
    field :role, Ecto.Enum, values: [:owner, :admin, :member]
    field :status, Ecto.Enum, values: [:pending, :accepted, :expired, :cancelled], default: :pending
    field :expires_at, :utc_datetime
    field :accepted_at, :utc_datetime
    
    belongs_to :account, Account
    belongs_to :invited_by, User
    
    timestamps()
  end
end
```

## Changeset Design

### Creation Changeset
Validates and prepares new invitations with automatic token generation and expiration setting. Ensures required fields are present and validates email format and role values.

### Status Update Changeset
Handles state transitions between pending, accepted, expired, and cancelled states. Automatically sets accepted_at timestamp when marking as accepted.

### Key Validations
- **Email Format**: Ensures valid email format using regex validation
- **Role Inclusion**: Validates role is one of the permitted account roles
- **Unique Constraints**: Prevents duplicate invitations (email + account combination)
- **Association Constraints**: Ensures referenced account and user exist

## Database Schema

### Index Strategy
- **Unique Token Index**: Fast token lookups for acceptance flow
- **Email + Account Unique Index**: Prevents duplicate invitations
- **Account Index**: Efficient queries for account-specific invitations
- **Email Index**: Quick lookups for user invitation history
- **Status Index**: Filtering by invitation status
- **Expiration Index**: Efficient cleanup of expired invitations

## Token Generation

### Security Requirements
Tokens must be cryptographically secure, URL-safe, and collision-resistant. Generated using Phoenix Tokens.

## State Machine

### Status Transitions
- **pending - accepted**: User successfully accepts invitation
- **pending - expired**: Invitation passes expiration date
- **pending - cancelled**: Admin cancels invitation
- **accepted**: Terminal state - no further transitions
- **expired**: Terminal state - no further transitions
- **cancelled**: Terminal state - no further transitions

### Expiration Handling
Default expiration is 7 days from creation. System automatically marks expired invitations through scheduled cleanup jobs. Expired invitations cannot be accepted.

## Business Rules

### Email Uniqueness
Only one pending invitation per email address per account. Prevents spam and confusion from multiple active invitations.

### Role Validation
Invited roles must be valid account roles and typically cannot exceed the inviting user's role (enforced at business logic level).

### Account Association
All invitations must belong to a valid account and be created by a user with appropriate permissions.

### Audit Trail
Complete history of invitation lifecycle is maintained through timestamps and status changes for security and compliance purposes.

This schema design provides a robust foundation for invitation management while maintaining data integrity and security requirements.