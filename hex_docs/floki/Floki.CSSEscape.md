# Floki.CSSEscape



## escape(value)

Escapes a string for use as a CSS identifier.

## Examples

    iex> Floki.CSSEscape.escape("hello world")
    "hello\\ world"

    iex> Floki.CSSEscape.escape("-123")
    "-\\31 23"