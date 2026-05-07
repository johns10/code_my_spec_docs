# Earmark.Parser.Parser



## parse_markdown(lines, options)

Given a markdown document (as either a list of lines or
a string containing newlines), return a parse tree and
the context necessary to render the tree.

The options are a `%Earmark.Parser.Options{}` structure. See `as_html!`
for more details.