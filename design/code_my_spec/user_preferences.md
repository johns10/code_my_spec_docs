# UserPreferences Context

## Purpose
Manages user preference data including active account selection, active project selection, and API token storage.

## Entity Ownership
- UserPreference schema (active_account_id, active_project_id, token)
- CRUD operations for user preferences
- Default preference creation for new users

## Scope Integration
### Accepted Scopes
- **Primary Scope**: `CodeMySpec.Users.Scope` - user-scoped access only

### Access Patterns
- All operations filtered by `user_id` from scope
- One preference record per user (unique constraint)
- Automatic creation of default preferences when none exist

## Public API
```elixir
# Preference retrieval
@spec get_user_preference(Scope.t()) :: {:ok, UserPreference.t()} | {:error, :not_found}
@spec get_user_preference!(Scope.t()) :: UserPreference.t()

# Preference modification
@spec update_user_preferences(Scope.t(), attrs :: map()) :: {:ok, UserPreference.t()} | {:error, Changeset.t()}
@spec create_user_preferences(Scope.t(), attrs :: map()) :: {:ok, UserPreference.t()} | {:error, Changeset.t()}
@spec delete_user_preferences(Scope.t()) :: {:ok, UserPreference.t()} | {:error, Changeset.t()}
@spec select_active_account(Scope.t(), account_id) :: {:ok, UserPreference.t()} | {:error, Changeset.t()}
@spec select_active_project(Scope.t(), project_id) :: {:ok, UserPreference.t()} | {:error, Changeset.t()}
@spec generate_token(Scope.t()) :: {:ok, UserPreference.t()} | {:error, Changeset.t()}

# Changeset generation
@spec change_user_preferences(Scope.t(), attrs :: map()) :: Changeset.t()
```

## State Management Strategy
### Persistence
- Single UserPreference record per user stored in PostgreSQL
- Unique constraint on user_id ensures one preference set per user
- Automatic creation of default preferences on first access

### Caching
- No caching layer - direct database access for simplicity
- Scope filtering ensures users only access their own preferences

### Transactions
- Individual operations are atomic
- No cross-context transactions required

## Component Diagram
```
UserPreferences (contains repository functions)
└── UserPreference (schema)
    ├── Changeset validation
    └── Database constraints
```

## Dependencies
- **CodeMySpec.Authorization**: Authorization logic
- **CodeMySpec.Users.Scope**: User scoping and access control
- **CodeMySpec.Repo**: Database operations
- **Ecto.Schema**: Schema definition and changesets
- **Ecto.Query**: Database queries with scope filtering

## Execution Flow
1. **Scope Validation**: Extract user_id from scope.user.id, return error if no user or different user
2. **Query Filtering**: All database operations filtered by user_id from scope
3. **Preference Retrieval**: Get existing preferences or create defaults automatically
4. **Changeset Validation**: Validate preference updates against schema constraints
5. **Database Persistence**: Save changes with scope-based access control
6. **Error Handling**: Return appropriate error tuples for missing data or validation failures