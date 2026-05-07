# Expo.PO

File handling for PO (`.po`) and POT (`.pot`) files.

## compose(messages)

Dumps a `Expo.Messages` struct as iodata.

This function dumps a `Expo.Messages` struct (representing a PO file) as iodata,
which can later be written to a file or converted to a string with
`IO.iodata_to_binary/1`.

## Examples

After running the following code:

    iodata =
      Expo.PO.compose(%Expo.Messages{
        headers: ["Last-Translator: Jane Doe"],
        messages: [
          %Expo.Message.Singular{msgid: ["foo"], msgstr: ["bar"], comments: "A comment"}
        ]
      })

    File.write!("/tmp/test.po", iodata)

the `/tmp/test.po` file would look like this:

    msgid ""
    msgstr ""
    "Last-Translator: Jane Doe"

    # A comment
    msgid "foo"
    msgstr "bar"

## parse_file(path, options \\ [])

Parses the contents of a file into a `Expo.Messages` struct.

This function works similarly to `parse_string/1` except that it takes a file
and parses the contents of that file. It can return:

  * `{:ok, po}` if the parsing is successful

  * `{:error, error}` if there is an error with the contents of the
    `.po` file (for example, a syntax error); `error` is an exception struct

  * `{:error, reason}` if there is an error with reading the file (this error
    is one of the errors that can be returned by `File.read/1`)

## Examples

    {:ok, po} = Expo.PO.parse_file("messages.po")
    po.file
    #=> "messages.po"

    Expo.PO.parse_file("nonexistent")
    #=> {:error, :enoent}

## parse_file!(path, opts \\ [])

Parses the contents of a file into a `Expo.Messages` struct, raising if there
are any errors.

Works like `parse_file/1`, except that it raises an exception
if there are issues with the contents of the file or with reading the file.

## Examples

    Expo.PO.parse_file!("nonexistent.po")
    #=> ** (File.Error) could not parse "nonexistent.po": no such file or directory

## parse_string(string, options \\ [])

Parses the given `string` into a `Expo.Messages` struct.

It returns `{:ok, messages}` if there are no errors, otherwise
`{:error, error}` where `error` is an exception struct.

## Examples

    iex> {:ok, po} = Expo.PO.parse_string("""
    ...> msgid "foo"
    ...> msgstr "bar"
    ...> """)
    iex> [message] = po.messages
    iex> message.msgid
    ["foo"]
    iex> message.msgstr
    ["bar"]
    iex> po.headers
    []

    iex> Expo.PO.parse_string("foo")
    {:error, %Expo.PO.SyntaxError{line: 1, reason: "unknown keyword 'foo'"}}

## parse_string!(string, opts \\ [])

Parses `string` into a `Expo.Messages` struct, raising an exception if there are
any errors.

Works exactly like `parse_string/1`, but returns a `Expo.Messages` struct
if there are no errors or raises an exception if there are.

## Examples

    iex> po = Expo.PO.parse_string!("""
    ...> msgid "foo"
    ...> msgstr "bar"
    ...> """)
    iex> [message] = po.messages
    iex> message.msgid
    ["foo"]
    iex> message.msgstr
    ["bar"]
    iex> po.headers
    []

    iex> Expo.PO.parse_string!("msgid")
    ** (Expo.PO.SyntaxError) 1: no space after 'msgid'

## parse_option/0

Parsing option.

  * `:file` (`t:Path.t/0`) - path to use in error messages when using `parse_string/2`. If not present, errors
    don't have a path.

  * `:strip_meta` (`t:boolean/0`) - include only messages (no comments and other metadata) from the `.po` file
  to reduce memory usage when meta information is not needed.
  Defaults to `false`.