# Finch.Request

A request struct.

## put_private(request, key, value)

Sets a new **private** key and value in the request metadata. This storage is meant to be used by libraries
and frameworks to inject information about the request that needs to be retrieved later on, for example,
from handlers that consume `Finch.Telemetry` events.

## method/0

An HTTP request method represented as an `atom()` or a `String.t()`.

The following atom methods are supported: `:get`, `:post`, `:put`, `:patch`, `:delete`, `:head`, `:options`.
You can use any arbitrary method by providing it as a `String.t()`.

## url/0

A Uniform Resource Locator, the address of a resource on the Web.

## headers/0

Request headers.

## body/0

Optional request body.