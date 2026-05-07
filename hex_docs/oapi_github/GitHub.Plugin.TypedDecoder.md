# GitHub.Plugin.TypedDecoder

Transform map responses into well-typed structs

In a normal client stack, the HTTP request is followed by a JSON decoder such as
`GitHub.Plugin.JasonSerializer`. If the JSON library/plugin does not support decoding typed
structs, then a separate step is necessary to transform the map responses into structs like
`GitHub.Repository`.

This module provides a two plugins: `decode_response/2` and `normalize_errors/2`, that accept no
configuration. `decode_response/2` uses the type information available in the operation and each
module's `__fields__/1` functions to decode the data. `normalize_errors/2` changes API error
responses into standard `GitHub.Error` results. It is recommended to run these plugins towards
the end of the stack, after decoding JSON responses.

The normalized errors will be `GitHub.Error` structs with relevant reason fields where possible.

## Special Cases

There are a few special cases where the decoder must make an inference about which type to use.
If you find that you are unable to decode something, please open an issue with information about
the operation and types involved.

Union types often require this kind of inference. This module handles them on a case-by-case
basis using required keys to determine the correct type. Some of these are done on a "best
guess" basis due to a lack of official documentation.

## decode(response, type)

Manually decode a response

This function takes a parsed response and decodes it using the given type. It is intended for
use in testing scenarios only. For regular API requests, use `decode_response/2` as part of the
client stack.

## decode_response(operation, opts)

Decode a response body based on type information from the operation and schemas

## normalize_errors(operation, opts)

Change API error responses into `GitHub.Error` results