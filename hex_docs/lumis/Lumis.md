# Lumis



## default_options/0

Returns all default options.

## available_languages/0

Returns the list of all available languages.

## Example

    iex> Lumis.available_languages()
    %{
      "diff" => {"Diff", ["*.diff"]},
      "lua" => {"Lua", ["*.lua"]},
      "javascript" => {"JavaScript", ["*.cjs", "*.js", "*.mjs", "*.snap", "*.jsx"]},
      "elixir" => {"Elixir", ["*.ex", "*.exs"]},
      ...
    }

    iex> Lumis.available_languages()["elixir"]
    {"Elixir", ["*.ex", "*.exs"]}

## available_themes/0

Returns the list of all available themes.

Use `Lumis.Theme.get/1` to get the actual theme struct.

## Example

    iex> Lumis.available_themes()
    ["github_light", "github_dark", "catppuccin_frappe", "catppuccin_latte", "nightfox", ...]

## highlight/2

Highlights `source` code and outputs into a formatted string.

## Options

See `t:options/0`.

## Examples

Defining the language name:

    iex> Lumis.highlight("Atom.to_string(:elixir)", language: "elixir")
    {
      :ok,
      <pre class="lumis" style="color: #abb2bf; background-color: #282c34;"><code class="language-elixir" translate="no" tabindex="0"><div class="line" data-line="1"><span style="color: #e5c07b;">Atom</span><span style="color: #56b6c2;">.</span><span style="color: #61afef;">to_string</span><span style="color: #c678dd;">(</span><span style="color: #e06c75;">:elixir</span><span style="color: #c678dd;">)</span>
      </div></code></pre>
    }

Guessing the language based on the provided source code:

    iex> Lumis.highlight("#!/usr/bin/env bash\nID=1")
    {:ok, "<pre class="lumis" ...><code class="language-bash" ...>...</code></pre>"}

With custom options:

    iex> Lumis.highlight("Atom.to_string(:elixir)", language: "example.ex", formatter: {:html_inline, pre_class: "example-elixir"})
    {:ok, "<pre class="lumis example-elixir" ...><code ...>...</code></pre>"}

Terminal formatter:

    iex> Lumis.highlight("Atom.to_string(:elixir)", language: "elixir", formatter: :terminal)
    {:ok, "[0m[38;2;229;192;123mAtom[0m[0m[38;2;86;182;194m.[0m[0m[38;2;97;175;239mto_string[0m[0m[38;2;198;120;221m([0m[0m[38;2;224;108;117m:elixir[0m[0m[38;2;198;120;221m)[0m"}

Highlighting specific lines in HTML Inline formatter:

    iex> code = """
    ...> defmodule Example do
    ...>   @lang = :elixir
    ...>   def lang, do: @lang
    ...> end
    ...> """
    iex> highlight_lines = %{lines: [2]}
    iex> Lumis.highlight(code, language: "elixir", formatter: {:html_inline, highlight_lines: highlight_lines})
    # Line 2 will be highlighted with the theme's `highlighted` style:
    <div class="line" style="background-color: #414858;" data-line="2">...</div>

Highlighting specific lines in HTML Linked formatter:
    
    iex> code = """
    ...> defmodule Example do
    ...>   @lang = :elixir
    ...>   def lang, do: @lang
    ...> end
    ...> """
    iex> highlight_lines = %{lines: [2]}
    iex> Lumis.highlight(code, language: "elixir", formatter: {:html_linked, highlight_lines: highlight_lines})
    # Line 2 will contain a `highlighted` class:
    <div class="line highlighted" data-line="2">...

Wrapping with custom HTML:

    iex> header = %{
    ...>   open_tag: "<figure><span>file: example.exs</span>",
    ...>   close_tag: "</figure>"
    ...> }
    iex> Lumis.highlight("IO.puts('hello')", language: "elixir", formatter: {:html_inline, header: header})
    # Returns: "<div class='code-block' data-lang='elixir'><pre class='lumis'>...</pre></div>"
    {:ok, "<figure><span>file: example.exs</span><pre...><code ...>...</code></pre></figure>"}

See https://docs.rs/lumis/latest/lumis/fn.highlight.html for more info.

## validate_options!/1

Validates the given options against the options schema.

This function validates the provided options using NimbleOptions and the defined schema.
It ensures that all options are valid and properly typed before being passed to the
highlighting functions.

## Examples

    iex> Lumis.validate_options!(language: "elixir")
    [language: "elixir", formatter: {:html_inline, [header: nil, highlight_lines: nil, include_highlights: false, italic: false, pre_class: nil, theme: "onedark"]}]

    iex> Lumis.validate_options!(formatter: {:html_inline, theme: "dracula"})
    [language: nil, formatter: {:html_inline, [theme: "dracula", ...]}]

    iex> Lumis.validate_options!(language: :invalid)
    ** (NimbleOptions.ValidationError)

## highlight!/2

Same as `highlight/2` but raises in case of failure.