# Earmark.Options

This is a superset of the options that need to be passed into `Earmark.Parser.as_ast/2`

The following options are proper to `Earmark` only and therefore explained in detail

- `compact_output`: boolean indicating to avoid indentation and minimize whitespace
- `eex`: Allows usage of an `EEx` template to be expanded to markdown before conversion
- `file`: Name of file passed in from the CLI
- `line`: 1 but might be set to an offset for better error messages in some integration cases
- `smartypants`: boolean use [Smarty Pants](https://daringfireball.net/projects/smartypants/) in the output
- `ignore_strings`, `postprocessor` and `registered_processors`: processors that modify the AST returned from

   Earmark.Parser.as_ast/`2` before rendering (`post` because preprocessing is done on the markdown, e.g. `eex`)
   Refer to the moduledoc of Earmark.`Transform` for details

All other options are passed onto Earmark.Parser.as_ast/`2`

## make_options(options \\ [])

Make a legal and normalized Option struct from, maps or keyword lists

Without a param or an empty input we just get a new Option struct

iex(1)> { make_options(), make_options(%{}) }
{ {:ok, %Earmark.Options{}}, {:ok, %Earmark.Options{}} }

The same holds for the bang version of course

iex(2)> { make_options!(), make_options!(%{}) }
{ %Earmark.Options{}, %Earmark.Options{} }


We check for unallowed keys

iex(3)> make_options(no_such_option: true)
{:error, [{:warning, 0, "Unrecognized option no_such_option: true"}]}

Of course we do not let our users discover one error after another

iex(4)> make_options(no_such_option: true, gfm: false, still_not_an_option: 42)
{:error, [{:warning, 0, "Unrecognized option no_such_option: true"}, {:warning, 0, "Unrecognized option still_not_an_option: 42"}]}

And the bang version will raise an `Earmark.Error` as excepted (sic)

iex(5)> make_options!(no_such_option: true, gfm: false, still_not_an_option: 42)
** (Earmark.Error) [{:warning, 0, "Unrecognized option no_such_option: true"}, {:warning, 0, "Unrecognized option still_not_an_option: 42"}]

Some values need to be numeric

iex(6)> make_options(line: "42")
{:error, [{:error, 0, "line option must be numeric"}]}

iex(7)> make_options(%Earmark.Options{footnote_offset: "42"})
{:error, [{:error, 0, "footnote_offset option must be numeric"}]}

iex(8)> make_options(%{line: "42", footnote_offset: nil})
{:error, [{:error, 0, "footnote_offset option must be numeric"}, {:error, 0, "line option must be numeric"}]}

## relative_filename(options, filename)

Allows to compute the path of a relative file name (starting with `"./"`) from the file in options
and return an updated options struct

iex(9)> options = %Earmark.Options{file: "some/path/xxx.md"}
...(9)> options_ = relative_filename(options, "./local.md")
...(9)> options_.file
"some/path/local.md"

For your convenience you can just use a keyword list

iex(10)> options = relative_filename([file: "some/path/_.md", breaks: true], "./local.md")
...(10)> {options.file, options.breaks}
{"some/path/local.md", true}

If the filename is not absolute it just replaces the file in options

iex(11)> options = %Earmark.Options{file: "some/path/xxx.md"}
...(11)> options_ = relative_filename(options, "local.md")
...(11)> options_.file
"local.md"

And there is a special case when processing stdin, meaning that `file: nil` we replace file
verbatim in that case

iex(12)> options = %Earmark.Options{}
...(12)> options_ = relative_filename(options, "./local.md")
...(12)> options_.file
"./local.md"

## with_postprocessor(pp, rps \\ [])

A convenience constructor