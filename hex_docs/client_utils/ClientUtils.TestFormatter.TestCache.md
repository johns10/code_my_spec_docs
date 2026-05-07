# ClientUtils.TestFormatter.TestCache

Caches test events to a JSON file, keyed by file.
Callers can query: "was file X tested after time Y?"

Uses JSON files for persistent storage that can be shared between
separate Erlang VM instances.

Events are stored as base64-encoded Erlang terms to preserve
all type information (tuples, structs, etc).

## clear()

Clears all cached events.

## close()

No-op for compatibility. JSON files don't need closing.

## destroy()

Deletes the events file entirely. Useful for cleanup.

## ensure_started()

No-op for compatibility. JSON files don't need setup.

## events_file()

Returns the events file path.
Uses the configured :agent_test_dir, or can be overridden via AGENT_TEST_EVENTS_FILE environment variable.

## extract_file(event)

Extracts the file path from a test event.

## file_tested_after?(file, requested_at)

Returns true if the file was tested after the given time.

## files_tested_after?(files, requested_at)

Returns true if all files were tested after the given time.
If files is empty, returns true (vacuous truth).

## get_events_after(after_time)

Gets all events from runs completed after the given time.

## get_events_for_file(file, after_time)

Gets all events for a file that were recorded after the given time.

## list_cached_files()

Returns a summary of all cached files with their timestamps.
Useful for debugging. Returns a list of {file, min_timestamp, max_timestamp, event_count}.

## setup()

No-op for compatibility. JSON files don't need setup.

## store_events(events, for_callers \\ [], tested_at \\ DateTime.utc_now())

Stores a batch of events to the JSON file as a new run.
`for_callers` is a list of PIDs (as strings) that this run is for.