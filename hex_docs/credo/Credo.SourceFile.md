# Credo.SourceFile

`SourceFile` structs represent a source file in the codebase.

## ast(source_file)

Returns the AST for the given `source_file`.

## column(source_file, line_no, trigger)

Returns the column of the given `trigger` inside the given line.

NOTE: Both `line_no` and the returned index are 1-based.

## line_at(source_file, line_no)

Returns the line at the given `line_no`.

NOTE: `line_no` is a 1-based index.

## line_at(source_file, line_no, column1, column2)

Returns the snippet at the given `line_no` between `column1` and `column2`.

NOTE: `line_no` is a 1-based index.

## lines(source_file)

Returns the lines of source code for the given `source_file`.

## parse(source, filename)

Returns a `SourceFile` struct for the given `source` code and `filename`.

## source(source_file)

Returns the source code for the given `source_file`.

## source_and_filename(source_file_or_source, default_filename \\ "nofilename")

Returns the source code and filename for the given `source_file_or_source`.