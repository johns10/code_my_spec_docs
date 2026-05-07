# Expo.Message.Plural

Struct for plural messages.

For example:

    msgid "Cat"
    msgid_plural "Cats"
    msgstr ""

See [`%Expo.Message.Plural{}`](`__struct__/0`) for documentation on the fields of this struct.

## %Expo.Message.Plural{}

The struct for a plural message.

All fields in this struct are public except for `:__meta__`. The `:flags` and `:references`
fields are defined as lists of lists in order to represent **lines** in the original file. For
example, this message:

    #, flag1, flag2
    #, flag3
    #: a.ex:1
    #: b.ex:2 c.ex:3
    msgid "Hello"
    msgstr ""

would have:

  * `flags: [["flag1", "flag2"], ["flag3"]]`
  * `references: [["a.ex:1"], ["b.ex:2", "c.ex:3"]]`

You can use `Expo.Message.has_flag?/2` to make it easier to check whether a message
has a given flag.

## key(message)

Returns the **key** of the message.

The key takes the msgctxt into consideration by returning a tuple `{msgctxt, msgid}`.
Both `msgctxt` and `msgid` are normalized to binaries (instead of keeping line information)
for easier comparison.

## Examples

    iex> Plural.key(%Plural{msgid: ["cat"], msgid_plural: ["cats"]})
    {"", "cat"}

## merge(message1, message2)

Merges two plural messages.

## Examples

    iex> msg1 = %Expo.Message.Plural{msgid: ["test"], msgid_plural: ["one"], flags: [["one"]], msgstr: %{0 => "une"}}
    ...> msg2 = %Expo.Message.Plural{msgid: ["test"], msgid_plural: ["two"], flags: [["two"]], msgstr: %{2 => "deux"}}
    ...> Expo.Message.Plural.merge(msg1, msg2)
    %Expo.Message.Plural{msgid: ["test"], msgid_plural: ["two"], flags: [["two", "one"]], msgstr: %{0 => "une", 2 => "deux"}}

## rebalance(message)

Re-balances all strings in the message.

This function does these things:

  * Put one string per newline of `msgid`/`msgid_plural`/`msgstr`
  * Put all flags onto one line
  * Put all references onto a separate line

### Examples

    iex> Plural.rebalance(%Plural{
    ...>   msgid: ["", "hello", "\n", "", "world", ""],
    ...>   msgid_plural: ["", "hello", "\n", "", "world", ""],
    ...>   msgstr: %{0 => ["", "hello", "\n", "", "world", ""]},
    ...>   flags: [["one", "two"], ["three"]],
    ...>   references: [[{"one", 1}, {"two", 2}], ["three"]]
    ...> })
    %Plural{
      msgid: ["hello\n", "world"],
      msgid_plural: ["hello\n", "world"],
      msgstr: %{0 => ["hello\n", "world"]},
      flags: [["one", "two", "three"]],
      references: [[{"one", 1}], [{"two", 2}], ["three"]]
    }

## source_line_number(message, block, default \\ nil)

Get the source line number of the message.

## Examples

    iex> %Expo.Messages{messages: [message]} = Expo.PO.parse_string!("""
    ...> msgid "foo"
    ...> msgid_plural "foos"
    ...> msgstr[0] "bar"
    ...> """)
    iex> Plural.source_line_number(message, :msgid)
    1
    iex> Plural.source_line_number(message, {:msgstr, 0})
    3

## block/0

The "component" of a message.

## t/0

The type for this struct.

See [`%__MODULE__{}`](`__struct__/0`) for documentation on the fields of this struct.

## meta/0

Metadata for this struct.

## key/0

The key that identifies this message.