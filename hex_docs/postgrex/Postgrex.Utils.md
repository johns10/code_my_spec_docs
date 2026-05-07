# Postgrex.Utils



## default_extension?(arg1)

Checks if a given extension is a default extension.

## default_extensions(opts \\ [])

List all default extensions.

## default_opts(opts)

Fills in the given `opts` with default options.
Only adds keys extracted via PGHOST if no endpoint-related keys are explicitly provided.

## encode_msg(observed, expected)

Return encode error message.

## encode_msg(type_info, observed, expected)

Return encode error message.

## parse_version(version)

Converts pg major.minor.patch (http://www.postgresql.org/support/versioning) version to an integer

## type_msg(type_info, module)

Return type error message.