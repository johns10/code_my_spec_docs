# Credo.Check.Design.DuplicatedCode

## Basics

> #### This check is disabled by default. {: .neutral}
>
> [Learn how to enable it](config_file.html#checks) via `.credo.exs`.

> #### This check is tagged `:controversial` {: .warning}
>
> This means that this check is more opinionated than others and not for everyone's taste.

This check has a base priority of `higher` and works with any version of Elixir.

## Explanation

Code should not be copy-pasted in a codebase when there is room to abstract
the copied functionality in a meaningful way.

That said, you should by no means "ABSTRACT ALL THE THINGS!".

Sometimes it can serve a purpose to have code be explicit in two places, even
if it means the snippets are nearly identical. A good example for this are
Database Adapters in a project like Ecto, where you might have nearly
identical functions for things like `order_by` or `limit` in both the
Postgres and MySQL adapters.

In this case, introducing an `AbstractAdapter` just to avoid code duplication
might cause more trouble down the line than having a bit of duplicated code.

Like all `Software Design` issues, this is just advice and might not be
applicable to your project/situation.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:mass_threshold`

  The minimum mass which a part of code has to have to qualify for this check.

*This parameter defaults to* `40`.

### `:nodes_threshold`

  The number of nodes that need to be found to raise an issue.

*This parameter defaults to* `2`.

### `:excluded_macros`

  List of macros to be excluded for this check.

*This parameter defaults to* `[]`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).

## calculate_hashes(ast, existing_hashes \\ %{}, filename \\ "foo.ex", mass_threshold \\ param_defaults()[:mass_threshold])

Calculates hash values for all sub nodes in a given +ast+.

Returns a map with the hashes as keys and the nodes as values.

## mass(ast)

Returns the mass (count of instructions) for an AST.

## prune_hashes(given_hashes, mass_threshold \\ param_defaults()[:mass_threshold])

Takes a map of hashes to nodes and prunes those nodes that are just
subnodes of others in the same set.

Returns the resulting map.

## to_hash(ast)

Returns a hash-value for a given +ast+.