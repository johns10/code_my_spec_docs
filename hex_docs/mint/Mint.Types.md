# Mint.Types

HTTP-related types.

## address/0

A hostname, IP address, Unix domain socket path, `:loopback`, or any
other term representing an internet address.

## request_ref/0

A request reference that uniquely identifies a request.

Responses for a request are always tagged with a request reference so that you
can connect each response to the right request. Also see `Mint.HTTP.request/5`.

## http2_response/0

An HTTP/2-specific response to a request.

This type of response is only returned on HTTP/2 connections. See `t:response/0` for
more response types.

## response/0

A response to a request.

Terms of this type are returned as responses to requests. See `Mint.HTTP.stream/2`
for more information.

## status/0

An HTTP status code.

The type for an HTTP is a generic non-negative integer since we don't formally check that
the response code is in the "common" range (`200..599`).

## headers/0

HTTP headers.

Headers are sent and received as lists of two-element tuples containing two strings,
the header name and header value.

## scheme/0

The scheme to use when connecting to an HTTP server.

## error/0

An error reason.

## socket/0

The connection socket.