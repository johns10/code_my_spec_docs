# Earmark.Parser.Options

Determines how markdown is parsed into an abstract syntax tree (AST) and subsequently rendered to HTML.

## normalize(options)

Use normalize before passing it into any API function

      iex(1)> options = normalize(annotations: "%%")
      ...(1)> options.annotations
      ~r{\A(.*)(%%.*)}