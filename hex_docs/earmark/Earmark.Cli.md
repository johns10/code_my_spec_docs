# Earmark.Cli

The Earmark CLI

Entry point of the escript, this is the **only** point that does IO with output and it uses the `Earmark.File` module which
is the **only** point that does IO with input.

## main/1

This is the entry point of the escript