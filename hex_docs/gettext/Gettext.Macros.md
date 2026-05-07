# Gettext.Macros

Macros used by Gettext to provide the gettext family of functions.

*Available since v0.26.0.*

Macros enable users to use gettext and get **automatic extraction** of translations.
See `Gettext` for more information.

The macros in this module *that don't end with `_with_backend`* are imported
every time you call:

    use Gettext, backend: MyApp.Gettext

### Explicit backend

If you need to use the macros here with an explicit backend and you want extraction
to work, you can use the `_with_backend` versions of the macros in this module explicitly
instead.

    defmodule MyApp.Gettext do
      use Gettext, otp_app: :my_app
    end

    defmodule MyApp.Controller do
      require Gettext.Macros

      def index(conn, _params) do
        Gettext.Macros.gettext_with_backend(MyApp.Gettext, "Hello, world!")
      end
    end

## dgettext(domain, msgid, bindings \\ Macro.escape(%{}))

Translates the given `msgid` in the given `domain`.

`bindings` is a map of bindings to support interpolation.

See also `Gettext.dgettext/4`.

## dgettext_noop(domain, msgid)

Marks the given message for extraction and returns it unchanged.

This macro can be used to mark a message for extraction when `mix
gettext.extract` is run. The return value is the given string, so that this
macro can be used seamlessly in place of the string to extract.

## Examples

    dgettext_noop("errors", "Error found!")
    #=> "Error found!"

## dgettext_noop_with_backend(backend, domain, msgid)

Same as `dgettext_noop/2`, but takes an explicit backend.

## dgettext_with_backend(backend, domain, msgid, bindings \\ Macro.escape(%{}))

Same as `dgettext/3`, but takes an explicit backend.

## dngettext(domain, msgid, msgid_plural, n, bindings \\ Macro.escape(%{}))

Translates the given plural message (`msgid` + `msgid_plural`) in the
given `domain`.

`n` is an integer used to determine how to pluralize the
message. `bindings` is a map of bindings to support interpolation.

See also `Gettext.dngettext/6`.

## dngettext_noop(domain, msgid, msgid_plural)

Marks the given message for extraction and returns
`{msgid, msgid_plural}`.

This macro can be used to mark a message for extraction when `mix
gettext.extract` is run. The return value of this macro is `{msgid,
msgid_plural}`.

## Examples

    my_fun = fn {msgid, msgid_plural} ->
      # do something with msgid and msgid_plural
    end

    my_fun.(dngettext_noop("errors", "One error", "%{count} errors"))

## dngettext_noop_with_backend(backend, domain, msgid, msgid_plural)

Same as `dngettext_noop/3`, but takes an explicit backend.

## dngettext_with_backend(backend, domain, msgid, msgid_plural, n, bindings \\ Macro.escape(%{}))

Same as `dngettext/5`, but takes an explicit backend.

## dpgettext(domain, msgctxt, msgid, bindings \\ Macro.escape(%{}))

Translates the given `msgid` with a given context (`msgctxt`) in the given `domain`.

`bindings` is a map of bindings to support interpolation.

See also `Gettext.dpgettext/5`.

## dpgettext_noop(domain, msgctxt, msgid)

Marks the given message for extraction and returns it unchanged.

This macro can be used to mark a message for extraction when `mix
gettext.extract` is run. The return value is the given string, so that this
macro can be used seamlessly in place of the string to extract.

## Examples

    dpgettext_noop("errors", "Home page", "Error found!")
    #=> "Error found!"

## dpgettext_noop_with_backend(backend, domain, msgctxt, msgid)

Same as `dpgettext_noop/3`, but takes an explicit backend.

## dpgettext_with_backend(backend, domain, msgctxt, msgid, bindings \\ Macro.escape(%{}))

Same as `dpgettext/4`, but takes an explicit backend.

## dpngettext(domain, msgctxt, msgid, msgid_plural, n, bindings \\ Macro.escape(%{}))

Translates the given plural message (`msgid` + `msgid_plural`) with the given context (`msgctxt`)
in the given `domain`.

`n` is an integer used to determine how to pluralize the
message. `bindings` is a map of bindings to support interpolation.

See also `Gettext.dpngettext/7`.

## dpngettext_noop(domain, msgctxt, msgid, msgid_plural)

Marks the given message for extraction and returns it unchanged.

This macro can be used to mark a message for extraction when `mix
gettext.extract` is run. The return value is the given string, so that this
macro can be used seamlessly in place of the string to extract.

## Examples

    dpngettext_noop("errors", "Home page", "Error found!", "Errors found!")
    #=> "Error found!"

## dpngettext_noop_with_backend(backend, domain, msgctxt, msgid, msgid_plural)

Same as `dpngettext_noop/4`, but takes an explicit backend.

## dpngettext_with_backend(backend, domain, msgctxt, msgid, msgid_plural, n, bindings \\ Macro.escape(%{}))

Same as `dpngettext/6`, but takes an explicit backend.

## gettext(msgid, bindings \\ Macro.escape(%{}))

Same as `dgettext("default", msgid, %{})`, but will use a per-backend
configured default domain if provided.

See also `Gettext.gettext/3`.

## gettext_comment(comment)

Stores an "extracted comment" for the next message.

This macro can be used to add comments (Gettext refers to such
comments as *extracted comments*) to the next message that will
be extracted. Extracted comments will be prefixed with `#.` in POT
files.

Calling this function multiple times will accumulate the comments;
when another Gettext macro (such as `gettext/2`) is called,
the comments will be extracted and attached to that message, and
they will be flushed so as to start again.

This macro always returns `:ok`.

## Examples

    gettext_comment("The next message is awesome")
    gettext_comment("Another comment for the next message")
    gettext("The awesome message")

## gettext_noop(msgid)

Marks the given message for extraction and returns it unchanged.

This macro can be used to mark a message for extraction when `mix
gettext.extract` is run. The return value is the given string, so that this
macro can be used seamlessly in place of the string to extract.

## Examples

    gettext_noop("Error found!")
    #=> "Error found!"

## gettext_noop_with_backend(backend, msgid)

Same as `gettext_noop/1`, but takes an explicit backend.

## gettext_with_backend(backend, msgid, bindings \\ Macro.escape(%{}))

Same as `gettext/2`, but takes an explicit backend.

## ngettext(msgid, msgid_plural, n, bindings \\ Macro.escape(%{}))

Same as `dngettext("default", msgid, msgid_plural, n, bindings)`, but will
use a per-backend configured default domain if provided.

See also `Gettext.ngettext/5`.

## ngettext_noop(msgid, msgid_plural)

Same as `dngettext_noop("default", msgid, mgsid_plural)`, but will use a
per-backend configured default domain if provided.

## ngettext_noop_with_backend(backend, msgid, msgid_plural)

Same as `ngettext_noop/2`, but takes an explicit backend.

## ngettext_with_backend(backend, msgid, msgid_plural, n, bindings \\ Macro.escape(%{}))

Same as `ngettext/4`, but takes an explicit backend.

## pgettext(msgctxt, msgid, bindings \\ Macro.escape(%{}))

Translates the given `msgid` with the given context (`msgctxt`).

`bindings` is a map of bindings to support interpolation.

See also `Gettext.pgettext/4`.

## pgettext_noop(msgid, context)

Marks the given message for extraction and returns it unchanged.

This macro can be used to mark a message for extraction when `mix
gettext.extract` is run. The return value is the given string, so that this
macro can be used seamlessly in place of the string to extract.

## Examples

    pgettext_noop("Error found!", "Home page")
    #=> "Error found!"

## pgettext_noop_with_backend(backend, msgctxt, msgid)

Same as `pgettext_noop/2`, but takes an explicit backend.

## pgettext_with_backend(backend, msgctxt, msgid, bindings \\ Macro.escape(%{}))

Same as `pgettext/3`, but takes an explicit backend.

## pngettext(msgctxt, msgid, msgid_plural, n, bindings \\ Macro.escape(%{}))

Translates the given plural message (`msgid` + `msgid_plural`) with the given context (`msgctxt`).

`n` is an integer used to determine how to pluralize the
message. `bindings` is a map of bindings to support interpolation.

See also `Gettext.pngettext/6`.

## pngettext_noop(msgctxt, msgid, msgid_plural)

Marks the given message for extraction and returns it unchanged.

This macro can be used to mark a message for extraction when `mix
gettext.extract` is run. The return value is the given string, so that this
macro can be used seamlessly in place of the string to extract.

## Examples

    pngettext_noop("Home page", "Error found!", "Errors found!")
    #=> "Error found!"

## pngettext_noop_with_backend(backend, msgctxt, msgid, msgid_plural)

Same as `pngettext_noop/3`, but takes an explicit backend.

## pngettext_with_backend(backend, msgctxt, msgid, msgid_plural, n, bindings \\ Macro.escape(%{}))

Same as `pngettext/5`, but takes an explicit backend.