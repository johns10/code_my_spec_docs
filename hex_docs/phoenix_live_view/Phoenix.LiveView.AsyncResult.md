# Phoenix.LiveView.AsyncResult

Provides a data structure for tracking the state of an async assign.

See the `Async Operations` section of the `Phoenix.LiveView` docs for more information.

## Fields

  * `:ok?` - When true, indicates the `:result` has been set successfully at least once.
  * `:loading` - The current loading state
  * `:failed` - The current failed state
  * `:result` - The successful result of the async task

## failed(result, reason)

Updates the failed state.

When failed, the loading state will be reset to `nil`.
If the result was previously `ok?`, both `result` and
`failed` will be set.

## Examples

    iex> result = AsyncResult.loading()
    iex> result = AsyncResult.failed(result, {:exit, :boom})
    iex> result.failed
    {:exit, :boom}
    iex> result.loading
    nil

## loading()

Creates an async result in loading state.

## Examples

    iex> result = AsyncResult.loading()
    iex> result.loading
    true
    iex> result.ok?
    false

## loading(result)

Updates the loading state.

When loading, the failed state will be reset to `nil`.

## Examples

    iex> result = AsyncResult.loading(%{my: :loading_state})
    iex> result.loading
    %{my: :loading_state}
    iex> result = AsyncResult.loading(result)
    iex> result.loading
    true

## loading(result, loading_state)

Updates the loading state of an existing `async_result`.

When loading, the failed state will be reset to `nil`.
If the result was previously `ok?`, both `result` and
`loading` will be set.

## Examples

    iex> result = AsyncResult.loading()
    iex> result = AsyncResult.loading(result, %{my: :other_state})
    iex> result.loading
    %{my: :other_state}

## ok(value)

Creates a successful result.

The `:ok?` field will also be set to `true` to indicate this result has
completed successfully at least once, regardless of future state changes.

### Examples

    iex> result = AsyncResult.ok("initial result")
    iex> result.ok?
    true
    iex> result.result
    "initial result"

## ok(result, value)

Updates the successful result.

The `:ok?` field will also be set to `true` to indicate this result has
completed successfully at least once, regardless of future state changes.

When ok'd, the loading and failed state will be reset to `nil`.

## Examples

    iex> result = AsyncResult.loading()
    iex> result = AsyncResult.ok(result, "completed")
    iex> result.ok?
    true
    iex> result.result
    "completed"
    iex> result.loading
    nil