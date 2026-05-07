# Recase.PathCase

Module to convert strings to `path/case`.

This module should not be used directly.

Path case preserves the original case,
but inserts path separator to appropriate places.

By default uses `/` as a path separator.

## Examples

    iex> Recase.to_path "foo_barBaz-λambdaΛambda-привет-Мир"
    "foo/bar/Baz/λambda/Λambda/привет/Мир"