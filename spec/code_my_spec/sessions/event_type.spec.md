# CodeMySpec.Sessions.EventType

Custom Ecto type for SessionEvent event_type that handles camelCase to snake_case conversion. Allows clients to send event types in camelCase (e.g., "proxyRequest") while storing them as snake_case atoms (e.g., :proxy_request) in the database. Validates against a predefined set of valid event types: proxy_request, proxy_response, session_start, session_end, notification, post_tool_use, user_prompt_submit, and stop.

## Delegates

None.

## Functions

### type/0

Returns the underlying Ecto type used for database storage.

```elixir
@spec type() :: :string
```

**Process**:
1. Return `:string` as the database storage type

**Test Assertions**:
- returns :string

### cast/1

Casts input from client (string or atom) to internal atom format. Handles both camelCase and snake_case input strings.

```elixir
@spec cast(binary() | atom() | any()) :: {:ok, atom()} | :error
```

**Process**:
1. If input is a binary string, convert from camelCase to snake_case using Recase.to_snake/1
2. Attempt to convert to an existing atom using String.to_existing_atom/1
3. If ArgumentError (atom doesn't exist), convert to atom using String.to_atom/1
4. Validate the resulting atom is in the valid types list
5. If input is an atom, directly validate against the valid types list
6. For any other input type, return :error

**Test Assertions**:
- returns {:ok, :proxy_request} when given "proxyRequest"
- returns {:ok, :proxy_request} when given "proxy_request"
- returns {:ok, :proxy_response} when given "proxyResponse"
- returns {:ok, :session_start} when given "sessionStart"
- returns {:ok, :session_end} when given "sessionEnd"
- returns {:ok, :notification} when given "notification"
- returns {:ok, :post_tool_use} when given "postToolUse"
- returns {:ok, :user_prompt_submit} when given "userPromptSubmit"
- returns {:ok, :stop} when given "stop"
- returns {:ok, :proxy_request} when given :proxy_request atom
- returns {:ok, :session_start} when given :session_start atom
- returns :error when given an invalid string
- returns :error when given an invalid atom
- returns :error when given nil
- returns :error when given a number
- returns :error when given a map

### load/1

Loads data from the database by converting the stored string back to an atom.

```elixir
@spec load(binary() | any()) :: {:ok, atom()} | :error
```

**Process**:
1. If input is a binary string, convert to an existing atom using String.to_existing_atom/1
2. Return {:ok, atom} on success
3. If ArgumentError (atom doesn't exist), return :error
4. For any other input type, return :error

**Test Assertions**:
- returns {:ok, :proxy_request} when loading "proxy_request"
- returns {:ok, :proxy_response} when loading "proxy_response"
- returns {:ok, :session_start} when loading "session_start"
- returns {:ok, :session_end} when loading "session_end"
- returns {:ok, :notification} when loading "notification"
- returns {:ok, :post_tool_use} when loading "post_tool_use"
- returns {:ok, :user_prompt_submit} when loading "user_prompt_submit"
- returns {:ok, :stop} when loading "stop"
- returns :error when loading an unknown string that isn't an existing atom
- returns :error when given nil
- returns :error when given an atom

### dump/1

Dumps data to the database by converting the atom to its string representation.

```elixir
@spec dump(atom() | any()) :: {:ok, binary()} | :error
```

**Process**:
1. If input is an atom in the valid types list, convert to string using Atom.to_string/1
2. Return {:ok, string}
3. If atom is not in valid types, return :error
4. For any other input type, return :error

**Test Assertions**:
- returns {:ok, "proxy_request"} when dumping :proxy_request
- returns {:ok, "proxy_response"} when dumping :proxy_response
- returns {:ok, "session_start"} when dumping :session_start
- returns {:ok, "session_end"} when dumping :session_end
- returns {:ok, "notification"} when dumping :notification
- returns {:ok, "post_tool_use"} when dumping :post_tool_use
- returns {:ok, "user_prompt_submit"} when dumping :user_prompt_submit
- returns {:ok, "stop"} when dumping :stop
- returns :error when dumping an invalid atom
- returns :error when dumping a string
- returns :error when dumping nil

## Dependencies

- Ecto.Type
- Recase
