# Phoenix.HTML

Building blocks for working with HTML in Phoenix.

This library provides three main functionalities:

  * HTML safety
  * Form abstractions
  * A tiny JavaScript library to enhance applications

## HTML safety

One of the main responsibilities of this package is to
provide convenience functions for escaping and marking
HTML code as safe.

By default, data output in templates is not considered
safe:

```heex
<%= "<hello>" %>
```

will be shown as:

```html
&lt;hello&gt;
```

User data or data coming from the database is almost never
considered safe. However, in some cases, you may want to tag
it as safe and show its "raw" contents:

```heex
<%= raw "<hello>" %>
```

## Form handling

See `Phoenix.HTML.Form`.

## JavaScript library

This project ships with a tiny bit of JavaScript that listens
to all click events to:

  * Support `data-confirm="message"` attributes, which shows
    a confirmation modal with the given message

  * Support `data-method="patch|post|put|delete"` attributes,
    which sends the current click as a PATCH/POST/PUT/DELETE
    HTTP request. You will need to add `data-to` with the URL
    and `data-csrf` with the CSRF token value

  * Dispatch a "phoenix.link.click" event. You can listen to this
    event to customize the behaviour above. Returning false from
    this event will disable `data-method`. Stopping propagation
    will disable `data-confirm`

To use the functionality above, you must load `priv/static/phoenix_html.js`
into your build tool.

### Overriding the default confirmation behaviour

You can override the default implementation by hooking
into `phoenix.link.click`. Here is an example:

```javascript
window.addEventListener('phoenix.link.click', function (e) {
  // Introduce custom behaviour
  var message = e.target.getAttribute("data-prompt");
  var answer = e.target.getAttribute("data-prompt-answer");
  if(message && answer && (answer != window.prompt(message))) {
    e.preventDefault();
  }
}, false);
```

## attributes_escape(attrs)

Escapes an enumerable of attributes, returning iodata.

The attributes are rendered in the given order. Note if
a map is given, the key ordering is not guaranteed.

The keys and values can be of any shape, as long as they
implement the `Phoenix.HTML.Safe` protocol. In addition,
if the key is an atom, it will be "dasherized". In other
words, `:phx_value_id` will be converted to `phx-value-id`.

Furthermore, the following attributes provide behaviour:

  * `:aria`, `:data`, and `:phx` - they accept a keyword list as
    value. `data: [confirm: "are you sure?"]` is converted to
    `data-confirm="are you sure?"`.

  * `:class` - it accepts a list of classes as argument. Each
    element in the list is separated by space. `nil` and `false`
    elements are discarded. `class: ["foo", nil, "bar"]` then
    becomes `class="foo bar"`.

  * `:id` - it is validated raise if a number is given as ID,
    which is not allowed by the HTML spec and leads to unpredictable
    behaviour.

## Examples

    iex> safe_to_string attributes_escape(title: "the title", id: "the id", selected: true)
    " title=\"the title\" id=\"the id\" selected"

    iex> safe_to_string attributes_escape(%{data: [confirm: "Are you sure?"]})
    " data-confirm=\"Are you sure?\""

    iex> safe_to_string attributes_escape(%{phx: [value: [foo: "bar"]]})
    " phx-value-foo=\"bar\""

## css_escape(value)

Escapes a string for use as a CSS identifier.

## Examples

    iex> css_escape("hello world")
    "hello\\ world"

    iex> css_escape("-123")
    "-\\31 23"

## html_escape(safe)

Escapes the HTML entities in the given term, returning safe iodata.

    iex> html_escape("<hello>")
    {:safe, [[[] | "&lt;"], "hello" | "&gt;"]}

    iex> html_escape(~c"<hello>")
    {:safe, ["&lt;", 104, 101, 108, 108, 111, "&gt;"]}

    iex> html_escape(1)
    {:safe, "1"}

    iex> html_escape({:safe, "<hello>"})
    {:safe, "<hello>"}

## javascript_escape(data)

Escapes HTML content to be inserted into a JavaScript string.

This function is useful in JavaScript responses when there is a need
to escape HTML rendered from other templates, like in the following:

    $("#container").append("<%= javascript_escape(render("post.html", post: @post)) %>");

It escapes quotes (double and single), double backslashes and others.

## raw(value)

Marks the given content as raw.

This means any HTML code inside the given
string won't be escaped.

    iex> raw("<hello>")
    {:safe, "<hello>"}
    iex> raw({:safe, "<hello>"})
    {:safe, "<hello>"}
    iex> raw(nil)
    {:safe, ""}

## safe_to_string(arg)

Converts a safe result into a string.

Fails if the result is not safe. In such cases, you can
invoke `html_escape/1` or `raw/1` accordingly before.

You can combine `html_escape/1` and `safe_to_string/1`
to convert a data structure to a escaped string:

    data |> html_escape() |> safe_to_string()

## safe/0

Guaranteed to be safe

## unsafe/0

May be safe or unsafe (i.e. it needs to be converted)