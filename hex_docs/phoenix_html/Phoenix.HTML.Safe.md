# Phoenix.HTML.Safe

Defines the HTML safe protocol.

In order to promote HTML safety, Phoenix templates
do not use `Kernel.to_string/1` to convert data types to
strings in templates. Instead, Phoenix uses this
protocol which must be implemented by data structures
and guarantee that a HTML safe representation is returned.

Furthermore, this protocol relies on iodata, which provides
better performance when sending or streaming data to the client.

## t/0

All the types that implement this protocol.