# NimbleCSV

NimbleCSV is a small and fast parsing and dumping library.

It works by building highly-inlined CSV parsers, designed
to work with strings, enumerables, and streams. At the top
of your file (and not inside a function), you can define your
own parser module:

    NimbleCSV.define(MyParser, separator: "\t", escape: "\"")

Once defined, we can parse data accordingly:

    iex> MyParser.parse_string("name\tage\njohn\t27")
    [["john","27"]]

See the `define/2` function for the list of functions that
would be defined in `MyParser`.

## Parsing

NimbleCSV is by definition restricted in scope to do only
parsing (and dumping). The example above discarded the
headers when parsing the string, as NimbleCSV expects
developers to handle those explicitly later.
For example:

    "name\tage\njohn\t27"
    |> MyParser.parse_string()
    |> Enum.map(fn [name, age] ->
      %{name: name, age: String.to_integer(age)}
    end)

This is particularly useful with the `c:parse_stream/1` functionality
that receives and returns a stream. For example, we can use it
to parse files line by line lazily:

    "path/to/csv/file"
    |> File.stream!(read_ahead: 100_000)
    |> MyParser.parse_stream()
    |> Stream.map(fn [name, age] ->
      %{name: :binary.copy(name), age: String.to_integer(age)}
    end)
    |> Stream.run()

By default this library ships with two implementations:

  * `NimbleCSV.RFC4180`, which is the most common implementation of
    CSV parsing/dumping available using comma as separators and
    double-quote as escape. If you want to use it in your codebase,
    simply alias it to CSV and enjoy:

        iex> alias NimbleCSV.RFC4180, as: CSV
        iex> CSV.parse_string("name,age\njohn,27")
        [["john","27"]]

  * `NimbleCSV.Spreadsheet`, which uses UTF-16 and is most commonly
    used by spreadsheet software, such as Excel, Numbers, etc.

### Binary references

One of the reasons behind NimbleCSV performance is that it performs
parsing by matching on binaries and extracting those fields as
binary references. Therefore, if you have a row such as:

    one,two,three,four,five

NimbleCSV will return a list of `["one", "two", "three", "four", "five"]`
where each element references the original row. For this reason, if
you plan to keep the parsed data around in the parsing process or even
send it to another process, you must copy the data before doing the transfer,
that's why we use `:binary.copy/1` in the examples above.

## Dumping

NimbleCSV can dump any enumerable to either iodata or to streams:

    iex> IO.iodata_to_binary MyParser.dump_to_iodata([~w(name age), ~w(mary 28)])
    "name\tage\nmary\t28\n"

    iex> MyParser.dump_to_stream([~w(name age), ~w(mary 28)])
    #Stream<[
      enum: [["name", "age"], ["mary", "28"]],
      funs: [#Function<47.127921642/1 in Stream.map/2>]
    ]>

## define(module, options)

Defines a new parser/dumper.

Calling this function defines a CSV module. Therefore, `define/2`
is typically invoked at the top of your files and not inside
functions. Placing it inside a function would cause the same
module to be defined multiple times, one time per invocation,
leading your code to emit warnings and slowing down execution.

It accepts the following options:

  * `:moduledoc` - the documentation for the generated module

The following options control parsing:

  * `:escape`- the CSV escape, defaults to `"\""`
  * `:encoding` - converts the given data from encoding to UTF-8
  * `:separator`- the CSV separators, defaults to `","`. It can be
    a string or a list of strings. If a list is given, the first entry
    is used for dumping (see below)
  * `:newlines` - the list of entries to be considered newlines
    when parsing, defaults to `["\r\n", "\n"]` (note they are attempted
    in order, so the order matters)
  * `:trim_bom` - automatically trims
    [BOM (byte-order marker)](https://en.wikipedia.org/wiki/Byte_order_mark)
    when parsing string. Note the BOM is not trimmed for enumerables or streams.
    In such cases, the BOM must be trimmed directly in the stream, such as
    `File.stream!(path, [:trim_bom])`

The following options control dumping:

  * `:escape`- the CSV escape character, defaults to `"\""`
  * `:encoding` - converts the given data from UTF-8 to the given encoding
  * `:separator`- the CSV separator character, defaults to `","`
  * `:line_separator` - the CSV line separator character, defaults to `"\n"`
  * `:dump_bom` - includes BOM (byte order marker) in the dumped document
  * `:reserved` - the list of characters to be escaped, defaults to the
    `:separator`, `:newlines`, and `:escape` characters above
  * `:escape_formula` - the formula prefix(es) and formula escape sequence,
     defaults to `nil`, which disabled formula escaping
     `%{["@", "+", "-", "=", "\t", "\r"] => "'"}` would escape all fields starting
     with `@`, `+`, `-`, `=`, tab or carriage return using the `'` character.

Although parsing may support multiple newline delimiters, when
dumping, only one of them must be picked, which is controlled by
the `:line_separator` option. This allows NimbleCSV to handle both
`"\r\n"` and `"\n"` when parsing, but only the latter for dumping.

## Parser/Dumper API

Modules defined with `define/2` implement the `NimbleCSV` behaviour. See
the callbacks for this behaviour for information on the generated functions
and their documentation.

## CSV Injection

By default, the dumper does not escape values which some clients may interpret
as formulas or commands. This can result in
[CSV injection](https://owasp.org/www-community/attacks/CSV_Injection).

There is no universally correct way to handle CSV injections. In some cases,
you may want formulas to be preserved: you may want a cell to have a value of
`=SUM(...)`. The only way to escape these values is by materially changing
them by prefixing a tab or single quote, which can also lead to false positives.

The `escape_formula` option will add a prefix to any value which has the
configured prefix (e.g. it will prepend `'` to any value which begins with
`@`, `+`, `-`, `=`, tab or carriage return). Use the following config to
follow the [OWASP recommendations](https://owasp.org/www-community/attacks/CSV_Injection):

    escape_formula: %{["@", "+", "-", "=", "\t", "\r"] => "'"}

Applications that want more control over this process, to allow formulas in specific
cases, or possibly minimize false positives, should leave this option disabled and
escape the value, as necessary, within their code.

## dump_to_iodata/1

Eagerly dumps an enumerable into iodata (a list of binaries and bytes and other lists).

## dump_to_stream/1

Lazily dumps from an enumerable to a stream.

It returns a stream that emits each row as iodata.

## parse_enumerable/1

Same as `parse_enumerable(enumerable, [])`.

## parse_enumerable/2

Eagerly parses CSV from an enumerable and returns a list of rows.

Raises `NimbleCSV.ParseError` for an invalid CSV.

## Options

  * `:skip_headers` - when `true`, skips headers. Defaults to `true`.
    Set it to `false` to keep headers or when the CSV has no headers.

## parse_stream/1

Same as `parse_stream(enumerable, [])`.

## parse_stream/2

Lazily parses CSV from a stream and returns a stream of rows.

It expects the given enumerable to be line-oriented, where each
entry in the enumerable is a line. If your stream does not conform
to that, you can call `c:to_line_stream/1` before parsing the stream.

Raises `NimbleCSV.ParseError` for an invalid CSV.

## Options

  * `:skip_headers` - when `true`, skips headers. Defaults to `true`.
    Set it to `false` to keep headers or when the CSV has no headers.

## parse_string/1

Same as `parse_string(enumerable, [])`.

## parse_string/2

Eagerly parses CSV from a string and returns a list of rows.

Raises `NimbleCSV.ParseError` for an invalid CSV.

## Options

  * `:skip_headers` - when `true`, skips headers. Defaults to `true`.
    Set it to `false` to keep headers or when the CSV has no headers.

## to_line_stream/1

Lazily convert a stream of arbitrarily chunked binaries to a line-oriented one.

This is useful for places where a CSV cannot be streamed in a
line-oriented fashion from its source.