# Earmark.Parser.Helpers



## escape(html)

Replace <, >, and quotes with the corresponding entities. If
`encode` is true, convert ampersands, too, otherwise only
 convert non-entity ampersands.

## expand_tabs(line)

Expand tabs to multiples of 4 columns

## extract_ial(line)

Returns a tuple containing a potentially present IAL and the line w/o the IAL

    iex(1)> extract_ial("# A headline")
    {nil, "# A headline"}

    iex(2)> extract_ial("# A classy headline{:.classy}")
    {".classy", "# A classy headline"}

An IAL line, remains an IAL line though

    iex(3)> extract_ial("{:.line-ial}")
    {nil, "{:.line-ial}"}

## remove_line_ending(line, annotation)

Remove newlines at end of line and optionally annotations

## replace(text, regex, replacement, options \\ [])

`Regex.replace` with the arguments in the correct order