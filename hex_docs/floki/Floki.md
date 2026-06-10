# Floki

Floki is a simple HTML parser that enables search for nodes using CSS selectors.

## Example

Assuming that you have the following HTML:

```html
<!doctype html>
<html>
<body>
  <section id="content">
    <p class="headline">Floki</p>
    <a href="http://github.com/philss/floki">Github page</a>
    <span data-model="user">philss</span>
  </section>
</body>
</html>
```

To parse this, you can use the function `Floki.parse_document/1`:

```elixir
{:ok, html} = Floki.parse_document(doc)
# =>
# [{"html", [],
#   [
#     {"body", [],
#      [
#        {"section", [{"id", "content"}],
#         [
#           {"p", [{"class", "headline"}], ["Floki"]},
#           {"a", [{"href", "http://github.com/philss/floki"}], ["Github page"]},
#           {"span", [{"data-model", "user"}], ["philss"]}
#         ]}
#      ]}
#   ]}]
```

With this document you can perform queries such as:

  * `Floki.find(html, "#content")`
  * `Floki.find(html, ".headline")`
  * `Floki.find(html, "a")`
  * `Floki.find(html, "[data-model=user]")`
  * `Floki.find(html, "#content a")`
  * `Floki.find(html, ".headline, a")`

Each HTML node is represented by a tuple like:

    {tag_name, attributes, children_nodes}

Example of node:

    {"p", [{"class", "headline"}], ["Floki"]}

So even if the only child node is the element text, it is represented
inside a list.

## parse_document!/2

Parses a HTML Document from a string.

Similar to `Floki.parse_document/1`, but raises `Floki.ParseError` if there was an
error parsing the document.

## Example

    iex> Floki.parse_document!("<html><head></head><body>hello</body></html>")
    [{"html", [], [{"head", [], []}, {"body", [], ["hello"]}]}]

## parse_fragment!/2

Parses a HTML fragment from a string.

Similar to `Floki.parse_fragment/1`, but raises `Floki.ParseError` if there was an
error parsing the fragment.

## find/2

Find elements inside an HTML tree or string.

## Examples

    iex> {:ok, html} = Floki.parse_fragment("<p><span class=hint>hello</span></p>")
    iex> Floki.find(html, ".hint")
    [{"span", [{"class", "hint"}], ["hello"]}]

    iex> {:ok, html} = Floki.parse_fragment("<div id=important><div>Content</div></div>")
    iex> Floki.find(html, "#important")
    [{"div", [{"id", "important"}], [{"div", [], ["Content"]}]}]

    iex> {:ok, html} = Floki.parse_fragment("<p><a href='https://google.com'>Google</a></p>")
    iex> Floki.find(html, "a")
    [{"a", [{"href", "https://google.com"}], ["Google"]}]

    iex> Floki.find([{ "div", [], [{"a", [{"href", "https://google.com"}], ["Google"]}]}], "div a")
    [{"a", [{"href", "https://google.com"}], ["Google"]}]

## attr/4

Changes the attribute values of the elements matched by `selector`
with the function `mutation` and returns the whole element tree.

## Examples

    iex> Floki.attr([{"div", [{"id", "a"}], []}], "#a", "id", fn(id) -> String.replace(id, "a", "b") end)
    [{"div", [{"id", "b"}], []}]

    iex> Floki.attr([{"div", [{"class", "name"}], []}], "div", "id", fn _ -> "b" end)
    [{"div", [{"id", "b"}, {"class", "name"}], []}]

## find_and_update/3

Searches for elements inside the HTML tree and update those that matches the selector.

It will return the updated HTML tree.

This function works in a way similar to `traverse_and_update`, but instead of updating
the children nodes, it will only updates the `tag` and `attributes` of the matching nodes.

If `fun` returns `:delete`, the HTML node will be removed from the tree.

## Examples

    iex> Floki.find_and_update([{"a", [{"href", "http://elixir-lang.com"}], ["Elixir"]}], "a", fn
    iex>   {"a", [{"href", href}]} ->
    iex>     {"a", [{"href", String.replace(href, "http://", "https://")}]}
    iex>   other ->
    iex>     other
    iex> end)
    [{"a", [{"href", "https://elixir-lang.com"}], ["Elixir"]}]

## text/2

Returns the text nodes from a HTML tree.

By default, it will perform a deep search through the HTML tree.
You can disable deep search with the option `deep` assigned to false.
You can include content of script or style tags by setting the `:js` or 
`:style` flags, respectively, to true.
You can specify a separator between nodes content.

## Options

  * `:deep` - A boolean option to control how deep the search for
    text is going to be. If `false`, only the level of the HTML node
    or the first level of the HTML document is going to be considered.
    Defaults to `true`.

  * `:js` - A boolean option to control if the contents of `<script>` tags
    should be considered as text. Defaults to `false`.

  * `:style` - A boolean to control if the contents of `<style>` tags
    should be considered as text. Defaults to `false`.

  * `:sep` - A separator string that is added between text nodes.
    Defaults to `""`.

  * `:include_inputs` - A boolean to control if `<input>` or `<textarea>`
    values should be included in the resultant string.
    Defaults to `false`.

  * `:html_parser` - The module of the backend that is responsible for parsing
    the HTML string. By default it is set to `Floki.HTMLParser.Mochiweb`.

## Examples

    iex> Floki.text({"div", [], [{"span", [], ["hello"]}, " world"]})
    "hello world"

    iex> Floki.text({"div", [], [{"span", [], ["hello"]}, " world"]}, deep: false)
    " world"

    iex> Floki.text({"div", [], [{"script", [], ["hello"]}, " world"]})
    " world"

    iex> Floki.text([{"input", [{"type", "date"}, {"value", "2017-06-01"}], []}], include_inputs: true)
    "2017-06-01"

    iex> Floki.text({"div", [], [{"script", [], ["hello"]}, " world"]}, js: true)
    "hello world"

    iex> Floki.text({"ul", [], [{"li", [], ["hello"]}, {"li", [], ["world"]}]}, sep: "-")
    "hello-world"

    iex> Floki.text([{"div", [], ["hello world"]}])
    "hello world"

    iex> Floki.text([{"p", [], ["1"]},{"p", [], ["2"]}])
    "12"

    iex> Floki.text({"div", [], [{"style", [], ["hello"]}, " world"]}, style: false)
    " world"

    iex> Floki.text({"div", [], [{"style", [], ["hello"]}, " world"]}, style: true)
    "hello world"

## children/2

Returns the direct child nodes of a HTML node.

By default, it will also include all texts. You can disable
this behaviour by using the option `include_text` to `false`.

If the given node is not an HTML tag, then it returns nil.

## Examples

    iex> Floki.children({"div", [], ["text", {"span", [], []}]})
    ["text", {"span", [], []}]

    iex> Floki.children({"div", [], ["text", {"span", [], []}]}, include_text: false)
    [{"span", [], []}]

    iex> Floki.children({:comment, "comment"})
    nil

## attribute/3

Returns a list with attribute values for a given selector.

## Examples

    iex> Floki.attribute([{"a", [{"href", "https://google.com"}], ["Google"]}], "a", "href")
    ["https://google.com"]

    iex> Floki.attribute(
    iex>   [{"a", [{"class", "foo"}, {"href", "https://google.com"}], ["Google"]}],
    iex>   "a",
    iex>   "class"
    iex> )
    ["foo"]

    iex> Floki.attribute(
    iex>   [{"a", [{"href", "https://e.corp.com"}, {"data-name", "e.corp"}], ["E.Corp"]}],
    iex>   "a[data-name]",
    iex>   "data-name"
    iex> )
    ["e.corp"]

## attribute/2

Returns a list with attribute values from elements.

## Examples

    iex> Floki.attribute([{"a", [{"href", "https://google.com"}], ["Google"]}], "href")
    ["https://google.com"]

    iex> Floki.attribute([{"a", [{"href", "https://google.com"}, {"data-name", "google"}], ["Google"]}], "data-name")
    ["google"]

## filter_out/2

Returns the nodes from a HTML tree that don't match the filter selector.

## Examples

    iex> Floki.filter_out({"div", [], [{"script", [], ["hello"]}, " world"]}, "script")
    {"div", [], [" world"]}

    iex> Floki.filter_out([{"body", [], [{"script", [], []}, {"div", [], []}]}], "script")
    [{"body", [], [{"div", [], []}]}]

    iex> Floki.filter_out({"div", [], [{:comment, "comment"}, " text"]}, :comment)
    {"div", [], [" text"]}

    iex> Floki.filter_out({"div", [], ["text"]}, :text)
    {"div", [], []}

## css_escape/1

Escapes a string for use as a CSS identifier.

## Examples

    iex> Floki.css_escape("hello world")
    "hello\\ world"

    iex> Floki.css_escape("-123")
    "-\\31 23"