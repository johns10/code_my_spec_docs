# ThousandIsland.Socket

Encapsulates a client connection's underlying socket, providing a facility to
read, write, and otherwise manipulate a connection from a client.

## close(socket)

Closes the given socket. Note that a socket is automatically closed when the handler
process which owns it terminates

## connection_information(socket)

Returns information about the SSL connection info, if transport is SSL.

## getopts(socket, options)

Gets the given flags on the socket

Errors are usually from :inet.posix(), however, SSL module defines return type as any()

## getstat(socket)

Returns statistics about the connection.

## handshake(socket)

Handshakes the underlying socket if it is required (as in the case of SSL sockets, for example).

This is normally called internally by `ThousandIsland.Handler` and does not need to be
called by implementations which are based on `ThousandIsland.Handler`

## negotiated_protocol(socket)

Returns information about the protocol negotiated during transport handshaking (if any).

## new(raw_socket, handler_config, span)

Creates a new socket struct based on the passed parameters.

This is normally called internally by `ThousandIsland.Handler` and does not need to be
called by implementations which are based on `ThousandIsland.Handler`

## peercert(socket)

Returns information in the form of `t:public_key.der_encoded()` about the peer certificate of the socket.

## peername(socket)

Returns information in the form of `t:ThousandIsland.Transport.socket_info()` about the remote end of the socket.

## recv(socket, length \\ 0, timeout \\ nil)

Returns available bytes on the given socket. Up to `length` bytes will be
returned (0 can be passed in to get the next 'available' bytes, typically the
next packet). If insufficient bytes are available, the function can wait `timeout`
milliseconds for data to arrive.

## secure?(socket)

Returns whether or not this protocol is secure.

## send(socket, data)

Sends the given data (specified as a binary or an IO list) on the given socket.

## sendfile(socket, filename, offset, length)

Sends the contents of the given file based on the provided offset & length

## setopts(socket, options)

Sets the given flags on the socket

Errors are usually from :inet.posix(), however, SSL module defines return type as any()

## shutdown(socket, way)

Shuts down the socket in the given direction.

## sockname(socket)

Returns information in the form of `t:ThousandIsland.Transport.socket_info()` about the local end of the socket.

## telemetry_span(socket)

Returns the telemetry span representing the lifetime of this socket

## upgrade(socket, module, opts)

Upgrades the transport of the socket to use the specified transport module, performing any client
handshaking that may be required. The passed options are blindly passed through to the new
transport module.

This is normally called internally by `ThousandIsland.Handler` and does not need to be
called by implementations which are based on `ThousandIsland.Handler`

## t/0

A reference to a socket along with metadata describing how to use it