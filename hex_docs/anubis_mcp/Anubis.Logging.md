# Anubis.Logging



## client_event(event, details, metadata \\ [])

Log client events with structured format.

## Options
  * metadata - Additional metadata including:
    * :level - The log level (:debug, :info, :warning, :error, etc.)

## message(direction, type, id, data, metadata \\ [])

Log protocol messages with automatic formatting and context.

## Parameters
  * direction - "incoming" or "outgoing"
  * type - message type (e.g., "request", "response", "notification", "error")
  * id - message ID (can be nil)
  * data - the message content
  * metadata - additional metadata to include with level option (:debug, :info, :warning, :error, etc.)

## server_event(event, details, metadata \\ [])

Log server events with structured format.

## Options
  * metadata - Additional metadata including:
    * :level - The log level (:debug, :info, :warning, :error, etc.)

## transport_event(event, details, metadata \\ [])

Log transport events with structured format.

## Options
  * metadata - Additional metadata including:
    * :level - The log level (:debug, :info, :warning, :error, etc.)