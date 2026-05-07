# Lumis

<p align="center">
  Syntax highlighter powered by Tree-sitter and Neovim themes.
</p>

<p align="center">
  <a href="https://lumis.sh">https://lumis.sh</a>
</p>

<div align="center">
  <a href="https://hex.pm/packages/lumis">
    <img alt="Hex Version" src="https://img.shields.io/hexpm/v/lumis">
  </a>

  <a href="https://hexdocs.pm/lumis">
    <img alt="Hex Docs" src="http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat">
  </a>

  <a href="https://opensource.org/licenses/MIT">
    <img alt="MIT" src="https://img.shields.io/hexpm/l/lumis">
  </a>
</div>

## Features

- 🌳 70+ languages with tree-sitter parsing
- 🎨 120+ Neovim themes
- 📝 HTML output with inline styles or CSS classes
- 🖥️ Terminal output with ANSI colors
- 🔍 Language auto-detection
- 🎯 Customizable formatting options
- ✨ Line highlighting with custom styling
- 🎁 Custom HTML wrappers for code blocks

## Installation

```elixir
def deps do
  [
    {:lumis, "~> 0.1"}
  ]
end
```

## Usage

### Basic Usage (HTML Inline)

```elixir
iex> Lumis.highlight!("Atom.to_string(:elixir)", language: "elixir")
~s|<pre class="lumis" style="color: #abb2bf; background-color: #282c34;"><code class="language-elixir" translate="no" tabindex="0"><div class="line" data-line="1"><span style="color: #e5c07b;">Atom</span><span style="color: #56b6c2;">.</span><span style="color: #61afef;">to_string</span><span style="color: #c678dd;">(</span><span style="color: #e06c75;">:elixir</span><span style="color: #c678dd;">)</span>
</span></code></pre>|
```

See the HTML Linked and Terminal formatters below for more options.

### Language Auto-detection

```elixir
iex> Lumis.highlight!("#!/usr/bin/env bash\nID=1")
~s|<pre class="lumis" style="color: #abb2bf; background-color: #282c34;"><code class="language-bash" translate="no" tabindex="0"><div class="line" data-line="1"><span style="color: #c678dd;">#!/usr/bin/env bash</span>
</div><div class="line" data-line="2"><span style="color: #d19a66;">ID</span><span style="color: #56b6c2;">=</span><span style="color: #d19a66;">1</span>
</span></code></pre>|
```

### Themes

Themes are sourced from popular Neovim colorschemes.

Use `Lumis.available_themes/0` to list all available themes. You can specify a theme by name in the formatter options, or use `Lumis.Theme.get/1` to get a specific theme struct if you need to inspect or manipulate its styles.

```elixir
# Using theme name in formatter options
iex> Lumis.highlight!("setTimeout(fun, 5000);", language: "js", formatter: {:html_inline, theme: "github_light"})
~s|<pre class="lumis" style="color: #1f2328; background-color: #ffffff;"><code class="language-javascript" translate="no" tabindex="0"><div class="line" data-line="1"><span style="color: #6639ba;">setTimeout</span><span style="color: #1f2328;">(</span><span style="color: #1f2328;">fun</span><span style="color: #1f2328;">,</span> <span style="color: #0550ae;">5000</span><span style="color: #1f2328;">)</span><span style="color: #1f2328;">;</span>
</span></code></pre>|

# Using theme struct
iex> theme = Lumis.Theme.get("github_light")
iex> Lumis.highlight!("setTimeout(fun, 5000);", language: "js", formatter: {:html_inline, theme: theme})
```

#### Bring Your Own Theme

You can also load custom themes from JSON files or strings:

```elixir
# Load from JSON file
{:ok, theme} = Lumis.Theme.from_file("/path/to/your/theme.json")
Lumis.highlight!("your code", theme: theme)

# Load from JSON string
theme_json = ~s({"name": "my_theme", "appearance": "dark", "highlights": {"comment": {"fg": "#808080"}}})
{:ok, theme} = Lumis.Theme.from_json(theme_json)
Lumis.highlight!("your code", theme: theme)
```

## Incomplete or Malformed code

It's also capable of handling incomplete or malformed code, useful for streaming like in a ChatGPT interface:

```elixir
iex> Lumis.highlight!("const header = document.getEl", language: "js")
~s|<pre class="lumis" style="color: #abb2bf; background-color: #282c34;"><code class="language-javascript" translate="no" tabindex="0"><div class="line" data-line="1"><span style="color: #c678dd;">const</span> <span style="color: #abb2bf;">header</span> <span style="color: #abb2bf;">=</span> <span style="color: #e86671;">document</span><span style="color: #848b98;">.</span><span style="color: #56b6c2;">getEl</span>
</span></code></pre>|
```

## Formatters

Lumis supports four output formatters:

All HTML formatters wrap each line in a `<div class="line">` element with a `data-line` attribute containing the line number, making it easy to add line numbers or implement line-based features in your application.

See the [Livebook examples](https://github.com/leandrocp/lumis/tree/main/examples) and [t:formatter/0](https://hexdocs.pm/lumis/Lumis.html#t:formatter/0) for more.

### HTML Inline (Default)

Generates HTML with inline styles for each token:

```elixir
iex> Lumis.highlight!("Atom.to_string(:elixir)", language: "elixir", formatter: :html_inline)
# or with options
iex> Lumis.highlight!("Atom.to_string(:elixir)", language: "elixir", formatter: {:html_inline, pre_class: "my-code", italic: true, include_highlights: true})
```

Options:
- `:pre_class` - CSS class for the `<pre>` tag
- `:italic` - enable italic styles
- `:include_highlights` - include highlight scope names in `data-highlight` attributes
- `:highlight_lines` - highlight specific lines with custom styling
- `:header` - wrap the highlighted code with custom HTML elements

### HTML Linked

Generates HTML with CSS classes for styling:

```elixir
iex> Lumis.highlight!("Atom.to_string(:elixir)", language: "elixir", formatter: :html_linked)
# or with options
iex> Lumis.highlight!("Atom.to_string(:elixir)", language: "elixir", formatter: {:html_linked, pre_class: "my-code"})
```

Options:
- `:pre_class` - CSS class for the `<pre>` tag
- `:highlight_lines` - highlight specific lines with custom CSS class
- `:header` - wrap the highlighted code with custom HTML elements

To use linked styles, you need to include one of the [available CSS themes](https://github.com/leandrocp/lumis/tree/main/priv/static/css) in your app.

For Phoenix apps, add this to your `endpoint.ex`:

```elixir
plug Plug.Static,
  at: "/themes",
  from: {:lumis, "priv/static/css/"},
  only: ["dracula.css"] # choose any theme you want
```

Then add the stylesheet to your template:

```html
<link phx-track-static rel="stylesheet" href={~p"/themes/dracula.css"} />
```

### HTML Multi-Themes

Generates HTML with CSS custom properties (variables) for multiple themes, enabling light/dark mode support. Inspired by [Shiki Dual Themes](https://shiki.style/guide/dual-themes).

```elixir
# Basic dual theme with CSS variables
iex> Lumis.highlight!("Atom.to_string(:elixir)",
  language: "elixir",
  formatter: {:html_multi_themes,
    themes: [light: "github_light", dark: "github_dark"]
  }
)

# With light-dark() function for automatic theme switching
iex> Lumis.highlight!("Atom.to_string(:elixir)",
  language: "elixir",
  formatter: {:html_multi_themes,
    themes: [light: "github_light", dark: "github_dark"],
    default_theme: "light-dark()"
  }
)
```

The generated HTML includes CSS custom properties like `--lumis-light`, `--lumis-dark`, `--lumis-{theme}-bg`, and font styling variables (`-font-style`, `-font-weight`, `-text-decoration`) that can be used with CSS media queries or JavaScript for theme switching:

```css
/* Automatic light/dark mode based on system preference */
@media (prefers-color-scheme: dark) {
  .lumis,
  .lumis span {
    color: var(--lumis-dark) !important;
    background-color: var(--lumis-dark-bg) !important;
    font-style: var(--lumis-dark-font-style) !important;
    font-weight: var(--lumis-dark-font-weight) !important;
    text-decoration: var(--lumis-dark-text-decoration) !important;
  }
}

/* Manual control with class-based switching */
html.dark .lumis,
html.dark .lumis span {
  color: var(--lumis-dark) !important;
  background-color: var(--lumis-dark-bg) !important;
  font-style: var(--lumis-dark-font-style) !important;
  font-weight: var(--lumis-dark-font-weight) !important;
  text-decoration: var(--lumis-dark-text-decoration) !important;
}
```

Options:
- `:themes` (required) - keyword list mapping theme identifiers to theme names, e.g., `[light: "github_light", dark: "github_dark"]`
- `:default_theme` - controls inline color rendering: theme identifier for inline colors, `"light-dark()"` for CSS function, or `nil` for CSS variables only
- `:css_variable_prefix` - custom CSS variable prefix (default: `"--lumis"`)
- `:pre_class` - CSS class for the `<pre>` tag
- `:italic` - enable italic styles
- `:include_highlights` - include highlight scope names in `data-highlight` attributes
- `:highlight_lines` - highlight specific lines with custom styling
- `:header` - wrap the highlighted code with custom HTML elements

### Terminal

Generates ANSI escape codes for terminal output:

```elixir
iex> Lumis.highlight!("Atom.to_string(:elixir)", language: "elixir", formatter: :terminal)
# or with options
iex> Lumis.highlight!("Atom.to_string(:elixir)", language: "elixir", formatter: {:terminal, theme: "github_light"})
```

Options:
- `:theme` - theme to apply styles

## Samples

Visit https://lumis.sh to check out some examples.

## Acknowledgements

* [Makeup](https://hex.pm/packages/makeup) for setting up the baseline and for the inspiration
* [Inkjet](https://crates.io/crates/inkjet) for the Rust implementation up to v0.2 and for the inspiration

## available_languages()

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

## available_themes()

Returns the list of all available themes.

Use `Lumis.Theme.get/1` to get the actual theme struct.

## Example

    iex> Lumis.available_themes()
    ["github_light", "github_dark", "catppuccin_frappe", "catppuccin_latte", "nightfox", ...]

## default_options()

Returns all default options.

## highlight(source, options \\ [])

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

## highlight!(source, options \\ [])

Same as `highlight/2` but raises in case of failure.

## validate_options!(options)

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

## language/0

A language name, filename, or path with extension.

See `Lumis.available_languages/0` to list all available languages or check out a list of [available languages](https://docs.rs/lumis/latest/lumis/#languages-available).

## Examples

    - "elixir"
    - ".ex"
    - "app.ex"
    - "lib/app.ex"

## theme/0

Theme used to apply styles on the highlighted source code.

See `Lumis.available_themes/0` to list all available themes or check out a list of [available themes](https://docs.rs/lumis/latest/lumis/#themes-available).

## html_inline_highlight_lines/0

Highlight lines options for Inline HTML formatter.

## html_linked_highlight_lines/0

Highlight lines options for Linked HTML formatter.

## header/0

Wraps the highlighted code with custom open and close HTML tags.

## html_multi_themes_options/0

Options for HTML Multi-Themes formatter.

The themes are specified as a keyword list where keys are CSS identifiers (atoms)
and values are theme names (strings) or Theme structs.

## formatter/0

Highlighter formatter and its options.

Available formatters: `:html_inline`, `:html_linked`, `:html_multi_themes`, `:terminal`

* `:html_inline` - generates `<span>` tags with inline styles for each token, for example: `<span style="color: #6eb4bff;">Atom</span>`.
* `:html_linked` - generates `<span>` tags with `class` representing the token type, for example: `<span class="keyword-special">Atom</span>`.
   Must link an external CSS in order to render colors, see more at [HTML Linked](https://hexdocs.pm/lumis/Lumis.html#module-html-linked).
* `:html_multi_themes` - generates HTML with CSS custom properties (variables) for multiple themes, enabling light/dark mode support.
   Inspired by [Shiki Dual Themes](https://shiki.style/guide/dual-themes).
* `:terminal` - generates ANSI escape codes for terminal output.

You can either pass the formatter as an atom to use default options or a tuple with the formatter name and options, so both are equivalent:

    # passing only the formatter name like below:
    :html_inline
    # is the same as passing an empty list of options:
    {:html_inline, []}

## Available Options:

* `html_inline`:

    - `:theme` (`t:theme/0` - default: `nil`) - the theme to apply styles on the highlighted source code.
    - `:pre_class` (`t:String.t/0` - default: `nil`) - the CSS class to append into the wrapping `<pre>` tag.
    - `:italic` (`t:boolean/0` - default: `false`) - enable italic style for the highlighted code.
    - `:include_highlights` (`t:boolean/0` - default: `false`) - include the highlight scope name in a `data-highlight` attribute. Useful for debugging.
    - `:highlight_lines` (`t:html_inline_highlight_lines/0` - default: `nil`) - highlight specific lines either using the theme `highlighted` style or with custom CSS styling.
    - `:header` (`t:header/0` - default: `nil`) - wrap the highlighted code with custom open and close HTML tags.

* `html_linked`:

    - `:pre_class` (`t:String.t/0` - default: `nil`) - the CSS class to append into the wrapping `<pre>` tag.
    - `:highlight_lines` (`t:html_linked_highlight_lines/0` - default: `nil`) - highlight specific lines either using the `highlighted` class from themes or with a custom CSS class.
    - `:header` (`t:header/0` - default: `nil`) - wrap the highlighted code with custom open and close HTML tags.

* `html_multi_themes`:

    - `:themes` (`keyword(theme())` - required) - keyword list of theme identifiers to theme names/structs. Theme identifiers become CSS class names and CSS variable prefixes. Example: `[light: "github_light", dark: "github_dark"]`.
    - `:default_theme` (`t:String.t/0` - default: `nil`) - controls inline color rendering: specify a theme identifier for inline colors, use `"light-dark()"` for CSS light-dark() function, or `nil` for CSS variables only.
    - `:css_variable_prefix` (`t:String.t/0` - default: `nil`) - CSS variable prefix (defaults to `"--lumis"` if nil). Generates variables like `--lumis-light` (color), `--lumis-light-bg` (background), `--lumis-light-font-style`, etc.
    - `:pre_class` (`t:String.t/0` - default: `nil`) - the CSS class to append into the wrapping `<pre>` tag.
    - `:italic` (`t:boolean/0` - default: `false`) - enable italic style for the highlighted code.
    - `:include_highlights` (`t:boolean/0` - default: `false`) - include the highlight scope name in a `data-highlight` attribute.
    - `:highlight_lines` (`t:html_inline_highlight_lines/0` - default: `nil`) - highlight specific lines (same as html_inline).
    - `:header` (`t:header/0` - default: `nil`) - wrap the highlighted code with custom open and close HTML tags.

* `terminal`:

    - `:theme` (`t:theme/0` - default: `nil`) - the theme to apply styles on the highlighted source code.

## Examples

### Inline HTML formatter with default options

    :html_inline

### Inline HTML formatter with custom options

    {:html_inline, theme: "onedark", pre_class: "example-01", include_highlights: true}

### HTML Inline: highlight specific lines

    # apply theme's `highlighted` style
    {:html_inline, highlight_lines: %{lines: [2..4, 6], style: :theme}}

    # style: :theme is the default
    {:html_inline, highlight_lines: %{lines: [1, 2, 3]}}

    # explicitly use theme style
    {:html_inline, highlight_lines: %{lines: [1, 2, 3], style: :theme}}

    # overrides default style
    {:html_inline, highlight_lines: %{lines: [1, 3..5, 8], style: "background-color: #fff3cd; border-left: 3px solid #ffc107;"}}

    # with only class and no style
    {:html_inline, highlight_lines: %{lines: [1, 2, 3], style: nil, class: "transition-colors duration-500 w-full inline-block bg-yellow-500"}}

### HTML Linked: highlight specific lines

    # use default `highlighted` class (already present in themes)
    {:html_linked, highlight_lines: %{lines: [2..4, 6]}}

    # use custom class
    {:html_linked, highlight_lines: %{lines: [1, 2, 3], class: "error-line"}}

### Wrap with custom open and close HTML tags

    header = %{
      open_tag: "<div class="code-header"><span>file: app.ex</span>",
      close_tag: "</div>"
    }
    {:html_inline, header: header}

### HTML Multi-Themes: Light/Dark mode support

    # Basic dual theme with CSS variables
    {:html_multi_themes, themes: [light: "github_light", dark: "github_dark"]}

    # With light-dark() function for automatic theme switching based on system preference
    {:html_multi_themes,
     themes: [light: "github_light", dark: "github_dark"],
     default_theme: "light-dark()"}

    # With inline colors for default theme and CSS variables for others
    {:html_multi_themes,
     themes: [light: "github_light", dark: "github_dark"],
     default_theme: "light"}

    # Multiple themes with custom prefix
    {:html_multi_themes,
     themes: [light: "github_light", dark: "github_dark", dim: "catppuccin_frappe"],
     css_variable_prefix: "--code"}

    # With Theme structs instead of strings
    light_theme = Lumis.Theme.get("github_light")
    dark_theme = Lumis.Theme.get("github_dark")
    {:html_multi_themes, themes: [light: light_theme, dark: dark_theme]}

### Terminal formatter

    :terminal

    {:terminal, theme: "github_light"}

See https://docs.rs/lumis/latest/lumis/enum.FormatterOption.html for more info.

## options/0

* `:language` (`t:Lumis.language/0`) - The language used to highlight source code.
  You can also pass a filename or extension, for eg: `"enum.ex"` or just `"ex"`. If no language is provided, the highlighter will
  try to guess it based on the content of the given source code. Use `Lumis.available_languages/0` to list all available languages. The default value is `nil`.

* `:formatter` (`t:Lumis.formatter/0`) - Formatter to apply on the highlighted source code. See the type doc for more info. The default value is `{:html_inline, [theme: "onedark"]}`.

* `:theme` - *This option is deprecated. Use :formatter instead.*

* `:inline_style` (`t:boolean/0`) - *This option is deprecated. Use :formatter instead.*

* `:pre_class` - *This option is deprecated. Use :formatter instead.*



See each option type for more info.