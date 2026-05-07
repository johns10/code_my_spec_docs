# Plug.HTML

Conveniences for generating HTML.

## html_escape(data)

Escapes the given HTML to string.

    iex> Plug.HTML.html_escape("foo")
    "foo"

    iex> Plug.HTML.html_escape("<foo>")
    "&lt;foo&gt;"

    iex> Plug.HTML.html_escape("quotes: \" & \'")
    "quotes: &quot; &amp; &#39;"

## html_escape_to_iodata(data)

Escapes the given HTML to iodata.

    iex> Plug.HTML.html_escape_to_iodata("foo")
    "foo"

    iex> Plug.HTML.html_escape_to_iodata("<foo>")
    [[[] | "&lt;"], "foo" | "&gt;"]

    iex> Plug.HTML.html_escape_to_iodata("quotes: \" & \'")
    [[[[], "quotes: " | "&quot;"], " " | "&amp;"], " " | "&#39;"]