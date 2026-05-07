# Floki.HTMLParser

A entry point to dynamic dispatch functions to
the configured HTML parser.

The configuration can be done with the `:html_parser`
option when calling the functions, or for the `:floki` application:

    Floki.parse_document(document, html_parser: Floki.HTMLParser.FastHtml)

Or:

    use Mix.Config
    config :floki, :html_parser, Floki.HTMLParser.Mochiweb

The default parser is Mochiweb, which comes with Floki.
You can also choose between Html5ever or FastHtml.

And it's possible to pass down options to the parsers using
the `parser_args` option.

This module is also a behaviour that those parsers must implement.