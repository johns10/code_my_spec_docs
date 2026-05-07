# DBConnection.Query

The `DBConnection.Query` protocol is responsible for preparing and
encoding queries.

All `DBConnection.Query` functions are executed in the caller process which
means it's safe to, for example, raise exceptions or do blocking calls as
they won't affect the connection process.

## decode(query, result, opts)

Decode a result using a query.

This function is called to decode a result after it is returned by a
connection callback module.

See `DBConnection.execute/3`.

## describe(query, opts)

Describe a query.

This function is called to describe a query after it is prepared using a
connection callback module.

See `DBConnection.prepare/3`.

## encode(query, params, opts)

Encode parameters using a query.

This function is called to encode a query before it is executed using a
connection callback module.

If this function raises `DBConnection.EncodeError`, then the query is
prepared once again.

See `DBConnection.execute/3`.

## parse(query, opts)

Parse a query.

This function is called to parse a query term before it is prepared using a
connection callback module.

See `DBConnection.prepare/3`.

## decode/3

Decode a result using a query.

This function is called to decode a result after it is returned by a
connection callback module.

See `DBConnection.execute/3`.

## describe/2

Describe a query.

This function is called to describe a query after it is prepared using a
connection callback module.

See `DBConnection.prepare/3`.

## encode/3

Encode parameters using a query.

This function is called to encode a query before it is executed using a
connection callback module.

If this function raises `DBConnection.EncodeError`, then the query is
prepared once again.

See `DBConnection.execute/3`.

## parse/2

Parse a query.

This function is called to parse a query term before it is prepared using a
connection callback module.

See `DBConnection.prepare/3`.

## t/0

All the types that implement this protocol.