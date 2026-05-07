# Earmark.EarmarkParserProxy

This acts as a proxy to adapt to changes in `Earmark.Parser`'s API

If no changes are needed it can delegate `as_ast` to `Earmark.Parser`

If changes are needed they will be realised in this modules `as_ast`
function.

For that reason `Earmark.Parser.as_ast/*` **SHALL NOT** be invoked
anywhere else in this code base

## as_ast(input, options)

An adapter to `Earmark.Parser.as_ast/*`