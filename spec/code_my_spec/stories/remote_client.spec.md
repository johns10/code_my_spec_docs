# CodeMySpec.Stories.RemoteClient

HTTP client for the Stories API using Req. Provides remote access to story CRUD operations when running in CLI/VSCode environments, communicating with the CodeMySpec server via authenticated HTTP requests.

## Dependencies

- CodeMySpec.Stories.Story
- CodeMySpec.Users.Scope
- CodeMySpecCli.Auth.OAuthClient
- Req

## Functions

### list_stories/1

Returns all stories accessible to the current scope via the remote API.

```elixir
@spec list_stories(Scope.t()) :: [Story.t()]
```

**Process**:
1. Make GET request to /api/stories with OAuth token
2. On success (200), deserialize each story from JSON response
3. On error, raise with failure reason

**Test Assertions**:

- returns list of stories on success
- raises on API error

### list_project_stories/1

Returns all stories for the active project via the remote API.

```elixir
@spec list_project_stories(Scope.t()) :: [Story.t()]
```

**Process**:
1. Make GET request to /api/stories-list/project with OAuth token
2. On success (200), deserialize each story from JSON response
3. On error, raise with failure reason

**Test Assertions**:

- returns list of project stories on success
- raises on API error

### list_project_stories_by_priority/1

Returns project stories ordered by priority via the remote API.

```elixir
@spec list_project_stories_by_priority(Scope.t()) :: [Story.t()]
```

**Process**:
1. Make GET request to /api/stories-list/by-priority with OAuth token
2. On success (200), deserialize each story from JSON response
3. On error, raise with failure reason

**Test Assertions**:

- returns list of stories ordered by priority
- raises on API error

### list_unsatisfied_stories/1

Returns stories that are not yet satisfied by a component.

```elixir
@spec list_unsatisfied_stories(Scope.t()) :: [Story.t()]
```

**Process**:
1. Make GET request to /api/stories-list/unsatisfied with OAuth token
2. On success (200), deserialize each story from JSON response
3. On error, raise with failure reason

**Test Assertions**:

- returns list of unsatisfied stories on success
- raises on API error

### list_component_stories/2

Returns stories associated with a specific component.

```elixir
@spec list_component_stories(Scope.t(), Ecto.UUID.t()) :: [Story.t()]
```

**Process**:
1. Make GET request to /api/stories-list/component/:component_id with OAuth token
2. On success (200), deserialize each story from JSON response
3. On 401 or authentication error, return empty list
4. On other errors, return empty list

**Test Assertions**:

- returns list of stories for the component on success
- returns empty list when not authenticated
- returns empty list on 401 response
- returns empty list on other errors

### get_story/2

Gets a single story by ID. Returns nil if not found.

```elixir
@spec get_story(Scope.t(), integer()) :: Story.t() | nil
```

**Process**:
1. Make GET request to /api/stories/:id with OAuth token
2. On success (200), deserialize story from JSON response
3. On 404, return nil
4. On error, raise with failure reason

**Test Assertions**:

- returns story when it exists
- returns nil when story doesn't exist (404)
- raises on API error

### get_story!/2

Gets a single story by ID. Raises Ecto.NoResultsError if not found.

```elixir
@spec get_story!(Scope.t(), integer()) :: Story.t()
```

**Process**:
1. Call get_story/2
2. If nil, raise Ecto.NoResultsError with Story queryable
3. Otherwise, return the story

**Test Assertions**:

- returns story when it exists
- raises Ecto.NoResultsError when story doesn't exist

### create_story/2

Creates a new story via the remote API.

```elixir
@spec create_story(Scope.t(), map()) :: {:ok, Story.t()} | {:error, Ecto.Changeset.t() | term()}
```

**Process**:
1. Make POST request to /api/stories with story attributes and OAuth token
2. On success (201), deserialize story and return {:ok, story}
3. On validation error (422), build changeset error and return {:error, changeset}
4. On other error, return {:error, reason}

**Test Assertions**:

- creates story with valid attributes and returns {:ok, story}
- returns {:error, changeset} with invalid attributes (422 response)
- returns {:error, reason} on API error

### update_story/3

Updates an existing story via the remote API.

```elixir
@spec update_story(Scope.t(), Story.t(), map()) :: {:ok, Story.t()} | {:error, :not_found | Ecto.Changeset.t() | term()}
```

**Process**:
1. Make PUT request to /api/stories/:id with story attributes and OAuth token
2. On success (200), deserialize story and return {:ok, story}
3. On 404, return {:error, :not_found}
4. On validation error (422), build changeset error and return {:error, changeset}
5. On other error, return {:error, reason}

**Test Assertions**:

- updates story with valid attributes and returns {:ok, story}
- returns {:error, :not_found} when story doesn't exist
- returns {:error, changeset} with invalid attributes (422 response)
- returns {:error, reason} on API error

### delete_story/2

Deletes a story via the remote API.

```elixir
@spec delete_story(Scope.t(), Story.t()) :: {:ok, Story.t()} | {:error, :not_found | term()}
```

**Process**:
1. Make DELETE request to /api/stories/:id with OAuth token
2. On success (200), deserialize deleted story and return {:ok, story}
3. On 404, return {:error, :not_found}
4. On other error, return {:error, reason}

**Test Assertions**:

- deletes story and returns {:ok, story} on success
- returns {:error, :not_found} when story doesn't exist
- returns {:error, reason} on API error

### set_story_component/3

Sets the component that satisfies a story.

```elixir
@spec set_story_component(Scope.t(), Story.t(), Ecto.UUID.t()) :: {:ok, Story.t()} | {:error, :not_found | Ecto.Changeset.t() | term()}
```

**Process**:
1. Make POST request to /api/stories/:id/set-component with component_id and OAuth token
2. On success (200), deserialize story and return {:ok, story}
3. On 404, return {:error, :not_found}
4. On validation error (422), build changeset error and return {:error, changeset}
5. On other error, return {:error, reason}

**Test Assertions**:

- sets component and returns {:ok, story} on success
- returns {:error, :not_found} when story doesn't exist
- returns {:error, changeset} when component doesn't exist (422 response)
- returns {:error, reason} on API error

### clear_story_component/2

Clears the component assignment from a story.

```elixir
@spec clear_story_component(Scope.t(), Story.t()) :: {:ok, Story.t()} | {:error, :not_found | term()}
```

**Process**:
1. Make POST request to /api/stories/:id/clear-component with OAuth token
2. On success (200), deserialize story and return {:ok, story}
3. On 404, return {:error, :not_found}
4. On other error, return {:error, reason}

**Test Assertions**:

- clears component and returns {:ok, story} with nil component_id
- returns {:error, :not_found} when story doesn't exist
- returns {:error, reason} on API error