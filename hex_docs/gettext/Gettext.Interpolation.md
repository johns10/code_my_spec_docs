# Gettext.Interpolation

Behaviour to provide Gettext string interpolation.

By default, Gettext uses `Gettext.Interpolation.Default` as the interpolation module.

## message_format/0

Defines the Gettext message format to be used when extracting.

The default interpolation module that ships with Gettext uses `"elixir-format"`.

See the [GNU Gettext
documentation](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html#index-msgstr).

## runtime_interpolate/2

Called to perform interpolation *at runtime*.

If successful, should return `{:ok, interpolated_string}`. If there
are missing bindings, should return `{:missing_bindings, partially_interpolated, missing}`
where `partially_interpolated` is a string with the available bindings interpolated.

## compile_interpolate/3

Called to perform interpolation *at compile time*.