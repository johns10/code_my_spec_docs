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

## with_postprocessor/2

A convenience constructor