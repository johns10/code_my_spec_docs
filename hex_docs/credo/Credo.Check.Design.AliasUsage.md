# Credo.Check.Design.AliasUsage

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `normal` and works with any version of Elixir.

## Explanation

Functions from other modules should be used via an alias if the module's
namespace is not top-level.

While this is completely fine:

    defmodule MyApp.Web.Search do
      def twitter_mentions do
        MyApp.External.TwitterAPI.search(...)
      end
    end

... you might want to refactor it to look like this:

    defmodule MyApp.Web.Search do
      alias MyApp.External.TwitterAPI

      def twitter_mentions do
        TwitterAPI.search(...)
      end
    end

The thinking behind this is that you can see the dependencies of your module
at a glance. So if you are attempting to build a medium to large project,
this can help you to get your boundaries/layers/contracts right.

As always: This is just a suggestion. Check the configuration options for
tweaking or disabling this check.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:excluded_namespaces`

  List of namespaces to be excluded for this check.

*This parameter defaults to* `["File", "IO", "Inspect", "Kernel", "Macro", "Supervisor", "Task", "Version"]`.

### `:excluded_lastnames`

  List of lastnames to be excluded for this check.

*This parameter defaults to* `["Access", "Agent", "Application", "Atom", "Base", "Behaviour", "Bitwise", "Code", "Date", "DateTime", "Dict", "Enum", "Exception", "File", "Float", "GenEvent", "GenServer", "HashDict", "HashSet", "Integer", "IO", "Kernel", "Keyword", "List", "Macro", "Map", "MapSet", "Module", "NaiveDateTime", "Node", "OptionParser", "Path", "Port", "Process", "Protocol", "Range", "Record", "Regex", "Registry", "Set", "Stream", "String", "StringIO", "Supervisor", "System", "Task", "Time", "Tuple", "URI", "Version"]`.

### `:if_nested_deeper_than`

  Only raise an issue if a module is nested deeper than this.

*This parameter defaults to* `0`.

### `:if_called_more_often_than`

  Only raise an issue if a module is called more often than this.

*This parameter defaults to* `0`.

### `:if_referenced`

  Raise an issue if a module is referenced by name, e.g. as an argument in a function call.

*This parameter defaults to* `false`.

### `:only`

  Regex or a list of regexes that specifies which modules to include for this check.
  
  `excluded_namespaces` and `excluded_lastnames` take precedence over this parameter.
  

*This parameter defaults to* `nil`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).