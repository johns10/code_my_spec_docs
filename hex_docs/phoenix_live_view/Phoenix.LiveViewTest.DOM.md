# Phoenix.LiveViewTest.DOM



## css_escape(value)

Escapes a string for use as a CSS identifier.

## Examples

    iex> css_escape("hello world")
    "hello\\ world"

    iex> css_escape("-123")
    "-\\31 23"

## find_static_views(lazy)

Find static information in the given HTML tree.

## to_lazy(tree)

Turns a tree into a lazy.

## to_tree(lazy, opts \\ [])

Turns a lazy into a tree.