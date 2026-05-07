# ThousandIsland.Transport

This module describes the behaviour required for Thousand Island to interact
with low-level sockets. It is largely internal to Thousand Island, however users
are free to implement their own versions of this behaviour backed by whatever
underlying transport they choose. Such a module can be used in Thousand Island
by passing its name as the `transport_module` option when starting up a server,
as described in `ThousandIsland`.

## accept/1

Wait for a client connection on the given listener socket. This call blocks until
such a connection arrives, or an error occurs (such as the listener socket being
closed).

## close/1

Closes the given socket.

## connection_information/1

Returns the SSL connection_info for the given socket. If the socket is not secure,
`{:error, :not_secure}` is returned.

## controlling_process/2

Transfers ownership of the given socket to the given process. This will always
be called by the process which currently owns the socket.

## getopts/2

Gets the given options on the socket.

## getstat/1

Returns stats about the connection on the socket.

## handshake/1

Performs an initial handshake on a new client connection (such as that done
when negotiating an SSL connection). Transports which do not have such a
handshake can simply pass the socket through unchanged.

## listen/2

Create and return a listener socket bound to the given port and configured per
the provided options.

## negotiated_protocol/1

Returns the protocol negotiated as part of handshaking. Most typically this is via TLS'
ALPN or NPN extensions. If the underlying transport does not support protocol negotiation
(or if one was not negotiated), `{:error, :protocol_not_negotiated}` is returned

## peercert/1

Returns the peer certificate for the given socket in the form of `t:public_key.der_encoded()`.
If the socket is not secure, `{:error, :not_secure}` is returned.

## peername/1

Returns information in the form of `t:socket_info()` about the remote end of the socket.

## recv/3

Returns available bytes on the given socket. Up to `num_bytes` bytes will be
returned (0 can be passed in to get the next 'available' bytes, typically the
next packet). If insufficient bytes are available, the function can wait `timeout`
milliseconds for data to arrive.

## secure?/0

Returns whether or not this protocol is secure.

## send/2

Sends the given data (specified as a binary or an IO list) on the given socket.

## sendfile/4

Sends the contents of the given file based on the provided offset & length

## setopts/2

Sets the given options on the socket. Should disallow setting of options which
are not compatible with Thousand Island

## shutdown/2

Shuts down the socket in the given direction.

## sockname/1

Returns information in the form of `t:socket_info()` about the local end of the socket.

## upgrade/2

Performs an upgrade of an existing client connection (for example upgrading
an already-established connection to SSL). Transports which do not support upgrading can return
`{:error, :unsupported_upgrade}`.

## listener_socket/0

A listener socket used to wait for connections

## listen_options/0

A listener socket options

## socket/0

A socket representing a client connection

## socket_info/0

Information about an endpoint, either remote ('peer') or local

## address/0

A socket address

## socket_stats/0

Connection statistics for a given socket

## socket_get_options/0

Options which can be set on a socket via setopts/2 (or returned from getopts/1)

## socket_set_options/0

Options which can be set on a socket via setopts/2 (or returned from getopts/1)

## way/0

The direction in which to shutdown a connection in advance of closing it

## on_listen/0

The return value from a listen/2 call

## on_accept/0

The return value from an accept/1 call

## on_controlling_process/0

The return value from a controlling_process/2 call

## on_handshake/0

The return value from a handshake/1 call

## on_upgrade/0

The return value from a upgrade/2 call

## on_shutdown/0

The return value from a shutdown/2 call

## on_close/0

The return value from a close/1 call

## on_recv/0

The return value from a recv/3 call

## on_send/0

The return value from a send/2 call

## on_sendfile/0

The return value from a sendfile/4 call

## on_getopts/0

The return value from a getopts/2 call

## on_setopts/0

The return value from a setopts/2 call

## on_sockname/0

The return value from a sockname/1 call

## on_peername/0

The return value from a peername/1 call

## on_peercert/0

The return value from a peercert/1 call

## on_connection_information/0

The return value from a connection_information/1 call

## on_negotiated_protocol/0

The return value from a negotiated_protocol/1 call