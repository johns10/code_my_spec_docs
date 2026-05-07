# Earmark.Parser.Helpers.LookaheadHelpers



## opens_inline_code(map)

Indicates if the _numbered_line_ passed in leaves an inline code block open.

If so returns a tuple whre the first element is the opening sequence of backticks,
and the second the linenumber of the _numbered_line_

Otherwise `{nil, 0}` is returned

## still_inline_code(map, old)

returns false if and only if the line closes a pending inline code
*without* opening a new one.
The opening backtix are passed in as second parameter.
If the function does not return false it returns the (new or original)
opening backtix