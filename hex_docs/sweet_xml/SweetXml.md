# SweetXml

`SweetXml` is a thin wrapper around `:xmerl`. It allows you to convert a
string or xmlElement record as defined in `:xmerl` to an elixir value such
as `map`, `list`, `char_list`, or any combination of these.

For normal sized documents, `SweetXml` primarily exposes 3 functions

  * `SweetXml.xpath/2` - return a value based on the xpath expression
  * `SweetXml.xpath/3` - similar to above but allowing nesting of mapping
  * `SweetXml.xmap/2` - return a map with keywords mapped to values returned
    from xpath

For something larger, `SweetXml` mainly exposes 1 function

  * `SweetXml.stream_tags/3` - stream a given tag or a list of tags, and
    optionally "discard" some dom elements in order to free memory during
    streaming for big files which cannot fit entirely in memory

## Examples

Simple Xpath:

    iex> import SweetXml
    iex> doc = "<h1><a>Some linked title</a></h1>"
    iex> doc |> xpath(~x"//a/text()")
    'Some linked title'

Nested Mapping:

    iex> import SweetXml
    iex> doc = "<body><header><p>Message</p><ul><li>One</li><li><a>Two</a></li></ul></header></body>"
    iex> doc |> xpath(~x"//header", message: ~x"./p/text()", a_in_li: ~x".//li/a/text()"l)
    %{a_in_li: ['Two'], message: 'Message'}

Streaming:

    iex> import SweetXml
    iex> doc = ["<ul><li>l1</li><li>l2", "</li><li>l3</li></ul>"]
    iex> SweetXml.stream_tags(doc, :li)
    ...> |> Stream.map(fn {:li, doc} ->
    ...>      doc |> SweetXml.xpath(~x"./text()")
    ...>    end)
    ...> |> Enum.to_list
    ['l1', 'l2', 'l3']

For more examples please see help for each individual functions

## The ~x Sigil

Warning ! Because we use `xmerl` internally, only XPath 1.0 paths are handled.

Notice in the above examples, we used the expression `~x"//a/text()"` to
define the path. The reason is it allows us to more precisely specify what
is being returned.

  * `~x"//some/path"`

    without any modifiers, `xpath/2` will return the value of the entity if
    the entity is of type `xmlText`, `xmlAttribute`, `xmlPI`, `xmlComment`
    as defined in `:xmerl`

  * `~x"//some/path"e`

    `e` stands for (e)ntity. This forces `xpath/2` to return the entity with
    which you can further chain your `xpath/2` call

  * `~x"//some/path"l`

    'l' stands for (l)ist. This forces `xpath/2` to return a list. Without
    `l`, `xpath/2` will only return the first element of the match

  * `~x"//some/path"el` - mix of the above

  * `~x"//some/path"k`

    'k' stands for (K)eyword. This forces `xpath/2` to return a Keyword instead of a Map.

  * `~x"//some/path"s`

    's' stands for (s)tring. This forces `xpath/2` to return the value as
    string instead of a char list.

  * `x"//some/path"o`

    'o' stands for (O)ptional. This allows the path to not exist, and will return nil.

  * `~x"//some/path"sl` - string list.

Notice also in the examples section, we always import SweetXml first. This
makes `x_sigil` available in the current scope. Without it, instead of using
`~x`, you can do the following

    iex> doc = "<h1><a>Some linked title</a></h1>"
    iex> doc |> SweetXml.xpath(%SweetXpath{path: '//a/text()', is_value: true, cast_to: false, is_list: false, is_keyword: false})
    'Some linked title'

Note the use of char_list in the path definition.

## parse(doc, opts \\ [])

Parse a document into a form ready to be used by `xpath/3` and `xmap/2`.

`doc` can be

- a byte list (iodata)
- a binary
- any enumerable of binaries (for instance `File.stream!/3` result)

`options` can be both:
* `xmerl`'s options as described on the [xmerl_scan](http://www.erlang.org/doc/man/xmerl_scan.html) documentation page,
  see [the erlang tutorial](http://www.erlang.org/doc/apps/xmerl/xmerl_examples.html) for some advanced usage.
    For example: `parse(doc, quiet: true)`
* `:dtd` to prevent DTD parsing or fetching, with the following possibilities:
  * `:none`, will prevent both internal and external entities, it is the recommended options on untrusted XML.
    This will override the option `{:rules, read_fun, write_fun, state}` if present;
  * `:all`, the default, for backward compatibility, allows all DTDs;
  * `:internal_only`, will block all attempt at external fetching;
  * `[only: entities]` where `entities` is either an atom for a single entity, or a list of atoms.
    If any other entity is defined in the XML, `parse` will raise on them.
    This will override the option `{:rules, read_fun, write_fun, state}` if present.

When `doc` is an enumerable, the `:cont_fun` option cannot be given.

Returns an `xmlElement` record.

## sigil_x(path, modifiers \\ ~c"")

`sigil_x/2` simply returns a `%SweetXpath{}` struct, with modifiers converted to
boolean fields:

    iex> SweetXml.sigil_x("//some/path", 'e')
    %SweetXpath{path: '//some/path', is_value: false, cast_to: false, is_list: false, is_keyword: false}

Or you can simply import and use the `~x` expression:

    iex> import SweetXml
    iex> ~x"//some/path"e
    %SweetXpath{path: '//some/path', is_value: false, cast_to: false, is_list: false, is_keyword: false}

Valid modifiers are `e`, `s`, `l` and `k`. Below is the full explanation

  * `~x"//some/path"`

    without any modifiers, `xpath/2` will return the value of the entity if
    the entity is of type `xmlText`, `xmlAttribute`, `xmlPI`, `xmlComment`
    as defined in `:xmerl`

  * `~x"//some/path"e`

    `e` stands for (e)ntity. This forces `xpath/2` to return the entity with
    which you can further chain your `xpath/2` call

  * `~x"//some/path"l`

    'l' stands for (l)ist. This forces `xpath/2` to return a list. Without
    `l`, `xpath/2` will only return the first element of the match

  * `~x"//some/path"el` - mix of the above

  * `~x"//some/path"k`

    'k' stands for (K)eyword. This forces `xpath/2` to return a Keyword instead of a Map.

  * `~x"//some/path"s`

    's' stands for (s)tring. This forces `xpath/2` to return the value as
    string instead of a char list.

  * `x"//some/path"o`

    'o' stands for (O)ptional. This allows the path to not exist, and will return nil.

  * `~x"//some/path"sl` - string list.

  * `~x"//some/path"i`

    'i' stands for (i)nteger. This forces `xpath/2` to return the value as
    integer instead of a char list.

  * `~x"//some/path"f`

    'f' stands for (f)loat. This forces `xpath/2` to return the value as
    float instead of a char list.

  * `~x"//some/path"il` - integer list

## stream(doc, options_callback)

> #### Soft Deprecation {: .warning}
>
> Will be later deprecated in favor of `stream!/2`.

Create an element stream from a XML `doc`.

This is a lower level API compared to `SweetXml.stream_tags`. You can use
the `options_callback` argument to get fine control of what data to be streamed.

- `doc` is an enumerable, data will be pulled during the result stream
  enumeration. e.g. `File.stream!("some_file.xml")`
- `options_callback` is an anonymous function `fn emit -> (xmerl_opts | opts)` use it to
  define your :xmerl callbacks and put data into the stream using
  `emit.(elem)` in the callbacks. More details are available with `parse/2`.

For example, here you define a stream of all `xmlElement` :

    iex> import Record
    iex> doc = ["<h1", "><a>Som", "e linked title</a><a>other</a></h1>"]
    iex> SweetXml.stream(doc, fn emit ->
    ...>   [
    ...>     hook_fun: fn
    ...>       entity, xstate when is_record(entity, :xmlElement)->
    ...>         emit.(entity)
    ...>         {entity, xstate}
    ...>       entity, xstate ->
    ...>         {entity,xstate}
    ...>     end
    ...>   ]
    ...> end) |> Enum.count
    3

## stream!(doc, options_callback)

Equivalent to `stream/2`, see `stream/2` for more details.
The difference is in the handling of the errors. The caller can use `try/1`,
whereas with `stream/3` trapping exits and handling messages was necessary.
May raise `SweetXml.XmerlFatal` or `SweetXml.DTDError`.

## stream_tags(doc, tags, options \\ [])

> #### Soft Deprecation {: .warning}
>
> Will be later deprecated in favor of `stream_tags!/3`.

Most common usage of streaming: stream a given tag or a list of tags, and
optionally "discard" some DOM elements in order to free memory during streaming
for big files which cannot fit entirely in memory.

Note that each matched tag produces it's own tree. If a given tag appears in
the discarded options, it is ignored.

- `doc` is an enumerable, data will be pulled during the result stream
  enumeration. e.g. `File.stream!("some_file.xml")`
- `tags` is an atom or a list of atoms you want to extract. Each stream element
  will be `{:tagname, xmlelem}`. e.g. :li, :header
- `options[:discard]` is the list of tag which will be discarded:
   not added to its parent DOM.
- More options details are available with `parse/2`.

## Examples

    iex> import SweetXml
    iex> doc = ["<ul><li>l1</li><li>l2", "</li><li>l3</li></ul>"]
    iex> SweetXml.stream_tags(doc, :li, discard: [:li])
    ...> |> Stream.map(fn {:li, doc} -> doc |> SweetXml.xpath(~x"./text()") end)
    ...> |> Enum.to_list
    ['l1', 'l2', 'l3']
    iex> SweetXml.stream_tags(doc, [:ul, :li])
    ...> |> Stream.map(fn {_, doc} -> doc |> SweetXml.xpath(~x"./text()") end)
    ...> |> Enum.to_list
    ['l1', 'l2', 'l3', nil]


Be careful if you set `options[:discard]`. If any of the discarded tags is nested
inside a kept tag, you will not be able to access them.

## Examples

    iex> import SweetXml
    iex> doc = ["<header>", "<title>XML</title", "><header><title>Nested</title></header></header>"]
    iex> SweetXml.stream_tags(doc, :header)
    ...> |> Stream.map(fn {_, doc} -> SweetXml.xpath(doc, ~x".//title/text()") end)
    ...> |> Enum.to_list
    ['Nested', 'XML']
    iex> SweetXml.stream_tags(doc, :header, discard: [:title])
    ...> |> Stream.map(fn {_, doc} -> SweetXml.xpath(doc, ~x"./title/text()") end)
    ...> |> Enum.to_list
    [nil, nil]

## stream_tags!(doc, tags, options \\ [])

Equivalent to `stream_tags/3`, see `stream_tags/3` for more details.
The difference is in the handling of the errors. The caller can use `try/1`,
whereas with `stream_tags/3` trapping exits and handling messages was necessary.
May raise `SweetXml.XmerlFatal` or `SweetXml.DTDError`.

## transform_by(sweet_xpath, fun)

Tags `%SweetXpath{}` with `fun` to be applied at the end of `xpath` query.

## Examples

    iex> import SweetXml
    iex> string_to_range = fn str ->
    ...>     [first, last] = str |> String.split("-", trim: true) |> Enum.map(&String.to_integer/1)
    ...>     first..last
    ...>   end
    iex> doc = "<weather><zone><name>north</name><wind-speed>5-15</wind-speed></zone></weather>"
    iex> doc
    ...> |> xpath(
    ...>      ~x"//weather/zone"l,
    ...>      name: ~x"//name/text()"s |> transform_by(&String.capitalize/1),
    ...>      wind_speed: ~x"./wind-speed/text()"s |> transform_by(string_to_range)
    ...>    )
    [%{name: "North", wind_speed: 5..15}]

## xmap(parent, mapping, options \\ false)

`xmap` returns a mapping with each value being the result of `xpath`.

Just as `xpath`, you can nest the mapping structure. Please see `xpath/3` for
more detail.

You can give the option `true` to get the result as a keyword list instead of a map.

## Examples

Simple:

    iex> import SweetXml
    iex> doc = "<h1><a>Some linked title</a></h1>"
    iex> doc |> xmap(a: ~x"//a/text()")
    %{a: 'Some linked title'}

With optional mapping:

    iex> import SweetXml
    iex> doc = "<body><header><p>Message</p><ul><li>One</li><li><a>Two</a></li></ul></header></body>"
    iex> doc |> xmap(message: ~x"//p/text()", a_in_li: ~x".//li/a/text()"l)
    %{a_in_li: ['Two'], message: 'Message'}

With optional mapping and nesting:

    iex> import SweetXml
    iex> doc = "<body><header><p>Message</p><ul><li>One</li><li><a>Two</a></li></ul></header></body>"
    iex> doc
    ...> |> xmap(
    ...>      message: ~x"//p/text()",
    ...>      ul: [
    ...>        ~x"//ul",
    ...>        a: ~x"./li/a/text()"
    ...>      ]
    ...>    )
    %{message: 'Message', ul: %{a: 'Two'}}
    iex> doc
    ...> |> xmap(
    ...>      message: ~x"//p/text()",
    ...>      ul: [
    ...>        ~x"//ul"k,
    ...>        a: ~x"./li/a/text()"
    ...>      ]
    ...>    )
    %{message: 'Message', ul: [a: 'Two']}
    iex> doc
    ...> |> xmap([
    ...>      message: ~x"//p/text()",
    ...>      ul: [
    ...>        ~x"//ul",
    ...>        a: ~x"./li/a/text()"
    ...>      ]
    ...>    ], true)
    [message: 'Message', ul: %{a: 'Two'}]

## Security

Whenever you are working with some xml that was not generated by your system,
it is highly recommended that you restrain some functionalities of XML
during the parsing. SweetXml allows in particular to prevent DTD parsing and fetching.
Unless you know exactly what kind of DTD you want to permit in your xml,
it is recommended that you use the following code example to prevent possible attacks:
```
doc
|> parse(dtd: :none)
|> xmap(specs, options)
```
For more details, see `parse/2`.

## xpath(parent, spec, subspec \\ [])

`xpath` allows you to query an XML document with XPath.

The second argument to xpath is a `%SweetXpath{}` struct. The optional third
argument is a keyword list, such that the value of each keyword is also
either a `%SweetXpath{}` or a list with head being a `%SweetXpath{}` and tail being
another keyword list exactly like before. Please see the examples below for better
understanding.

## Examples

Simple:

    iex> import SweetXml
    iex> doc = "<h1><a>Some linked title</a></h1>"
    iex> doc |> xpath(~x"//a/text()")
    'Some linked title'

With optional mapping:

    iex> import SweetXml
    iex> doc = "<body><header><p>Message</p><ul><li>One</li><li><a>Two</a></li></ul></header></body>"
    iex> doc |> xpath(~x"//header", message: ~x"./p/text()", a_in_li: ~x".//li/a/text()"l)
    %{a_in_li: ['Two'], message: 'Message'}

With optional mapping and nesting:

    iex> import SweetXml
    iex> doc = "<body><header><p>Message</p><ul><li>One</li><li><a>Two</a></li></ul></header></body>"
    iex> doc
    ...> |> xpath(
    ...>      ~x"//header",
    ...>      ul: [
    ...>        ~x"./ul",
    ...>        a: ~x"./li/a/text()"
    ...>      ]
    ...>    )
    %{ul: %{a: 'Two'}}

## Security

Whenever you are working with some xml that was not generated by your system,
it is highly recommended that you restrain some functionalities of XML
during the parsing. SweetXml allows in particular to prevent DTD parsing and fetching.
Unless you know exactly what kind of DTD you want to permit in your xml,
it is recommended that you use the following code example to prevent possible attacks:
```
doc
|> parse(dtd: :none)
|> xpath(spec, subspec)
```
For more details, see `parse/2`.