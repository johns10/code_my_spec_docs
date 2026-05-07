# SexySpex.ErrorCapture

Captures error logs during spex execution.

This module provides a way to detect if any error logs were emitted during
test execution, allowing spex to fail if errors occur even if no assertion failed.

## Usage

In your spex file, enable error capture:

    use SexySpex, fail_on_error_logs: true

Or start/stop manually:

    SexySpex.ErrorCapture.start()
    # ... run tests ...
    errors = SexySpex.ErrorCapture.get_errors()
    SexySpex.ErrorCapture.stop()

## How It Works

Uses an ETS table to store captured errors and a custom Logger handler
to intercept error-level log messages.

## check_and_raise!()

Checks for errors and raises if any were found.

## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.

## clear()

Clears all captured errors.

## error_count()

Returns error count.

## format_errors()

Formats captured errors for display.

## get_errors()

Returns all captured errors.

## has_errors?()

Returns true if any errors were captured.

## start()

Starts the error capture process and installs the Logger handler.

## stop()

Stops the error capture process and removes the Logger handler.