# Mint.WebSocket.Extension

Tools for defining extensions to the WebSocket protocol

The WebSocket protocol allows for extensions which act as middle-ware
in the encoding and decoding of frames. In `Mint.WebSocket`, extensions are
written as module which implement the `Mint.WebSocket.Extension` behaviour.

The common "permessage-deflate" extension is built-in to `Mint.WebSocket` as
`Mint.WebSocket.PerMessageDeflate`. This extension should be used as a
reference when writing future extensions, but future extensions should be
written as separate libraries which extend `Mint.WebSocket` instead of
built-in. Also note that extensions must operate on the internal
representations of frames using the records defined in an internal module.

## decode/2

Invoked when decoding frames after receiving them from the wire

Error tuples bubble up to `Mint.WebSocket.decode/2`.

## encode/2

Invoked when encoding frames before sending them across the wire

Error tuples bubble up to `Mint.WebSocket.encode/2`.

## init/2

Invoked when the WebSocket server accepts an extension

This callback should be used to initialize any `:state` that the extension
needs to operate. For example, this callback is used by the
"permessage-deflate" extension to setup `t::zlib.zstream()`s and store
them in state.

The `all_extensions` argument is passed so that the extension can know
about the existence and ordering of other extensions. This can be useful
if a client declares multiple extensions which accomplish the same job
(such as multiple compression extensions) but want to only enable one based
on what the server accepts.

Note that extensions are initialized in the order in which the server accepts
them: any extensions preceeding `this_extension` in `all_extensions` are
initialized while any extensions after `this_extension` are not yet
initialized.

Error tuples bubble up to `Mint.WebSocket.upgrade/4`.

## name/0

Returns the name of the WebSocket extension

This should not include the parameters for the extension, such as
"client_max_window_bits" for the "permessage-deflate" extension.

## Examples

    iex> Mint.WebSocket.PerMessageDeflate.name()
    "permessage-deflate"

## params/0

Parameters to configure an extension

Some extensions can be configured by negotiation between the client and
server. For example "permessage-deflate" usually shows up as in the
"sec-websocket-extensions" header literally like so:

```text
Sec-WebSocket-Extensions: permessage-deflate
```

But the zlib window sizes and reset behavior can be negotiated with parameters
with headers like so

```text
Sec-WebSocket-Extensions: permessage-deflate; client_no_context_takeover; client_max_window_bits=12
```

These can be configured by passing parameters to any element passed in the
`:extensions` option to `Mint.WebSocket.upgrade/4`.

For example, one might write the above parameter configuration as

```elixir
[
  {Mint.WebSocket.PerMessageDeflate,
   [client_no_context_takeover: true, client_max_window_bits: 12]}
]
```

when passing the `:extensions` option to `Mint.WebSocket.upgrade/4`.

Note that `Mint.WebSocket.upgrade/4` will normalize the parameters of an
extension to a list of two-tuples with string keys and values. For example,
the above would be normalized to this extensions list:

```elixir
[
  %Mint.WebSocket.Extension{
    name: "permessage-deflate",
    module: Mint.WebSocket.PerMessageDeflate,
    params: [
      {"client_no_context_takeover", "true"},
      {"client_max_window_bits", "12"}
    ],
    state: nil,
    opts: []
  }
]
```

## t/0

A structure representing an instance of an extension

Extensions are implemented as modules but passed to `Mint.WebSocket` as
`Mint.WebSocket.Extension` structs with the following keys:

* `:name` - the name of the extension. When using the short-hand tuple
  syntax to pass extensions to `Mint.WebSocket.upgrade/4`, the name is
  determined by calling the `c:name/0` callback.
* `:module` - the module which implements the callbacks defined in the
  `Mint.WebSocket.Extension` behavior.
* `:state` - an arbitrary piece of data curated by the extension. For
  example, the "permessage-deflate" extension uses this field to
  hold `t:zlib.zstream()`s for compression and decompression.
* `:params` - a list with key-value tuples or atom/string keys which configure
  the parameters communicated to the server. All params are encoded into the
  "sec-websocket-extensions" header. Also see the documentation for
  `t:params/0`.
* `:opts` - a keyword list to pass configuration to the extension. These
  are not encoded into the "sec-websocket-extensions" header. For example,
  `:opts` is used by the "permessage-deflate" extension to configure `:zlib`
  configuration.