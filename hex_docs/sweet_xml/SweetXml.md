# SweetXml



## parse/2

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

## stream_tags/3

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

## stream_tags!/3

Equivalent to `stream_tags/3`, see `stream_tags/3` for more details.
The difference is in the handling of the errors. The caller can use `try/1`,
whereas with `stream_tags/3` trapping exits and handling messages was necessary.
May raise `SweetXml.XmerlFatal` or `SweetXml.DTDError`.

## stream/2

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

## stream!/2

Equivalent to `stream/2`, see `stream/2` for more details.
The difference is in the handling of the errors. The caller can use `try/1`,
whereas with `stream/3` trapping exits and handling messages was necessary.
May raise `SweetXml.XmerlFatal` or `SweetXml.DTDError`.

## transform_by/2

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