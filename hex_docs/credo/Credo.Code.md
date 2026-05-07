# Credo.Code

`Credo.Code` contains a lot of utility or helper functions that deal with the
analysis of - you guessed it - code.

Whenever a function serves a general purpose in this area, e.g. getting the
value of a module attribute inside a given module, we want to extract that
function and put it in the `Credo.Code` namespace, so others can utilize them
without reinventing the wheel.

## ast(string_or_source_file)

Returns an AST for a given `String` or `Credo.SourceFile`.

## clean_charlists_strings_and_sigils(source_file_or_source)

Takes a SourceFile and returns its source code stripped of all Strings and
Sigils.

## clean_charlists_strings_sigils_and_comments(source_file_or_source, sigil_replacement \\ " ")

Takes a SourceFile and returns its source code stripped of all Strings, Sigils
and code comments.

## contains_child?(parent, child)

Returns true if the given `child` AST node is part of the larger
`parent` AST node.

## postwalk(ast_or_source_file, fun, accumulator \\ [])

Postwalks a given `Credo.SourceFile`'s AST or a given AST.

Technically this is just a wrapper around `Macro.postwalk/3`.

## prewalk(ast_or_source_file, fun, accumulator \\ [])

Prewalks a given `Credo.SourceFile`'s AST or a given AST.

Technically this is just a wrapper around `Macro.prewalk/3`.

## remove_metadata(ast)

Returns an AST without its metadata.

## to_lines(string_or_source_file)

Converts a String or `Credo.SourceFile` into a List of tuples of `{line_no, line}`.

## to_tokens(string_or_source_file)

Converts a String or `Credo.SourceFile` into a List of tokens using the `:elixir_tokenizer`.

## find_child(parent, pattern)

Returns the first child that matches the given `pattern` in the `parent` AST node.