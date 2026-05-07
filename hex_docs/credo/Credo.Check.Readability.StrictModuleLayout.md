# Credo.Check.Readability.StrictModuleLayout

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:controversial` {: .warning}
>
> This means that this check is more opinionated than others and not for everyone's taste.

This check has a base priority of `low` and works with any version of Elixir.

## Explanation

Provide module parts in a required order.

    # preferred

    defmodule MyMod do
      @moduledoc "moduledoc"
      use Foo
      import Bar
      alias Baz
      require Qux
    end

Like all `Readability` issues, this one is not a technical concern.
But you can improve the odds of others reading and liking your code by making
it easier to follow.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:order`

  List of atoms identifying the desired order of module parts.
  
  Supported values are:
  
  - `:moduledoc` - `@moduledoc` module attribute
  - `:shortdoc` - `@shortdoc` module attribute
  - `:behaviour` - `@behaviour` module attribute
  - `:use` - `use` expression
  - `:import` - `import` expression
  - `:alias` - `alias` expression
  - `:require` - `require` expression
  - `:defstruct` - `defstruct` expression
  - `:opaque` - `@opaque` module attribute
  - `:type` - `@type` module attribute
  - `:typep` - `@typep` module attribute
  - `:callback` - `@callback` module attribute
  - `:macrocallback` - `@macrocallback` module attribute
  - `:optional_callbacks` - `@optional_callbacks` module attribute
  - `:module_attribute` - other module attribute
  - `:public_fun` - public function
  - `:private_fun` - private function or a public function marked with `@doc false`
  - `:public_macro` - public macro
  - `:private_macro` - private macro or a public macro marked with `@doc false`
  - `:callback_impl` - public function or macro marked with `@impl`
  - `:public_guard` - public guard
  - `:private_guard` - private guard or a public guard marked with `@doc false`
  - `:module` - inner module definition (`defmodule` expression inside a module)
  
  Notice that the desired order always starts from the top.
  
  For example, if you provide the order `~w/public_fun private_fun/a`,
  it means that everything else (e.g. `@moduledoc`) must appear after
  function definitions.
  

*This parameter defaults to* `[:shortdoc, :moduledoc, :behaviour, :use, :import, :alias, :require]`.

### `:ignore`

  List of atoms identifying the module parts which are not checked, and may
  therefore appear anywhere in the module. Supported values are the same as
  in the `:order` param.
  

*This parameter defaults to* `[]`.

### `:ignore_module_attributes`

  List of atoms identifying the module attributes which are not checked, and may
  therefore appear anywhere in the module. Useful for custom DSLs that use attributes
  before function heads.
  
  For example, if you provide `~w/trace/a`, all `@trace` attributes will be ignored.
  

*This parameter defaults to* `[]`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).