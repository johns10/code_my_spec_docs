# Expo.Messages

A struct that represents lists of `Expo.Message.Singular` and `Expo.Message.Plural`
structs for MO and PO files.

All fields in the struct are public. See [`%Expo.Messages{}`](`__struct__/0`).

## %Expo.Messages{}

The struct to represent a list of messages.

For the type of each field, see `t:t/0`.

## find(messages, message_to_find)

Finds a given `message_to_find` in a list of `messages`.

Equality between messages is checked using `Expo.Message.same?/2`.

Returns `nil` if `message_to_find` is not found.

## get_header(messages, header_name)

Gets a header by name.

The name of the header is case-insensitive.

### Examples

    iex> messages = %Expo.Messages{headers: ["Language: en_US\n"], messages: []}
    iex> Expo.Messages.get_header(messages, "language")
    ["en_US"]

    iex> messages = %Expo.Messages{headers: ["Language: en_US\n"], messages: []}
    iex> Expo.Messages.get_header(messages, "invalid")
    []

## rebalance(messages)

Re-balances all strings.

This function does the following things:

  * Re-balances all headers (see `Expo.Message.Singular.rebalance/1` and
    `Expo.Message.Plural.rebalance/1`)

  * Puts one string per newline of `headers` and add one empty line at start

### Examples

    iex> Expo.Messages.rebalance(%Expo.Messages{
    ...>   headers: ["", "hello", "\n", "", "world", ""],
    ...>   messages: [%Expo.Message.Singular{
    ...>     msgid: ["", "hello", "\n", "", "world", ""],
    ...>     msgstr: ["", "hello", "\n", "", "world", ""]
    ...>   }]
    ...> })
    %Expo.Messages{
      headers: ["", "hello\n", "world"],
      messages: [%Expo.Message.Singular{
        msgid: ["hello\n", "world"],
        msgstr: ["hello\n", "world"]
      }]
    }

## t/0

The type for this struct.