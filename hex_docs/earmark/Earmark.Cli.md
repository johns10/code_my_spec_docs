# Earmark.Cli

The Earmark CLI

Entry point of the escript, this is the **only** point that does IO with output and it uses the `Earmark.File` module which
is the **only** point that does IO with input.

## main(argv)

This is the entry point of the escript

## run!(argv)

A convenience wrapper around `Earmark.Cli.Implementation.run/1` it will return `str` in case `{:stdio, str}` is returned
or raise an error otherwise

    iex(0)> run!(["test/fixtures/short1.md"])
    "<h1>\nHeadline1</h1>\n<hr class=\"thin\">\n<h2>\nHeadline2</h2>\n"