# Lumis.Theme

A Neovim theme.

Contains the name, appearance, and a map of highlight `Lumis.Theme.Style`'s.

Lumis bundles the most popular themes from the Neovim community,
you can see the full list with `Lumis.available_themes/0` and
then fetch one of the bundled themes with `Lumis.Theme.get/1`.

Or check out all the [available themes](https://docs.rs/lumis/latest/lumis/#themes-available).

## Example

    %Lumis.Theme{
       name: "github_light",
       appearance: :light,
       revision: "fe70a27afefa6e10db4a59262d31f259f702fd6a",
       highlights: %{
         "function.macro" => %Lumis.Theme.Style{
           fg: "#6639ba",
           bg: nil,
           bold: false,
           italic: false,
           text_decoration: %Lumis.Theme.TextDecoration{
             underline: :solid,
             strikethrough: false
           }
         },
         ...
       }
    }

## get/2

Get a theme by name.

## from_file/1

Load a theme from a JSON file.

## from_json/1

Load a theme from a JSON string.