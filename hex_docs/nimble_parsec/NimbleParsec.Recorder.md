# NimbleParsec.Recorder



## record(module, parser_kind, combinator_kind, name, combinators, inline, opts)

Records the given call and potentially debugs it.

## replay(contents, id)

Replays recorded parsers on the given content.

## start_link(opts)

Starts the recorder server.

## stop()

Stops the recorder server.