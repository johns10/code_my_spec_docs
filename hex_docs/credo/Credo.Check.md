# Credo.Check

`Check` modules represent the checks which are run during Credo's analysis.

Example:

    defmodule MyCheck do
      use Credo.Check, category: :warning, base_priority: :high

      def run(%SourceFile{} = source_file, params) do
        #
      end
    end

The check can be configured by passing the following
options to `use Credo.Check`:

- `:base_priority`  Sets the checks's base priority (`:low`, `:normal`, `:high`, `:higher` or `:ignore`).
- `:category`       Sets the check's category (`:consistency`, `:design`, `:readability`, `:refactor`  or `:warning`).
- `:elixir_version` Sets the check's version requirement for Elixir (defaults to `>= 0.0.1`).
- `:explanations`   Sets explanations displayed for the check, e.g.

    ```elixir
    [
      check: "...",
      params: [
        param1: "Your favorite number",
        param2: "Online/Offline mode"
      ]
    ]
    ```

- `:param_defaults` Sets the default values for the check's params (e.g. `[param1: 42, param2: "offline"]`)
- `:tags`           Sets the tags for this check (list of atoms, e.g. `[:tag1, :tag2]`)

Please also note that these options to `use Credo.Check` are just a convenience to implement the `Credo.Check`
behaviour. You can implement any of these by hand:

    defmodule MyCheck do
      use Credo.Check

      def category, do: :warning

      def base_priority, do: :high

      def explanations do
        [
          check: "...",
          params: [
            param1: "Your favorite number",
            param2: "Online/Offline mode"
          ]
        ]
      end

      def param_defaults, do: [param1: 42, param2: "offline"]

      def run(%SourceFile{} = source_file, params) do
        #
      end
    end

The `run/2` function of a Check module takes two parameters: a source file and a list of parameters for the check.
It has to return a list of found issues.

## format_issue(issue_meta, opts, check)

format_issue takes an issue_meta and returns an issue.
The resulting issue can be made more explicit by passing the following
options to `format_issue/2`:

- `:priority`     Sets the issue's priority.
- `:trigger`      Sets the issue's trigger, i.e. the text causing the issue (see `Credo.Check.Warning.IoInspect`).
- `:line_no`      Sets the issue's line number. Tries to find `column` if `:trigger` is supplied.
- `:column`       Sets the issue's column.
- `:exit_status`  Sets the issue's exit_status.
- `:severity`     Sets the issue's severity.
- `:category`     Sets the issue's category.

## to_exit_status(atom)

Converts a given category to an exit status

## base_priority/0

Returns the base priority for the check.

This can be one of `:higher`, `:high`, `:normal`, `:low` or `:ignore`
(technically it can also be  or an integer, but these are internal representations although that is not recommended).

## category/0

Returns the category for the check.

## docs_uri/0

Returns the docs URL for the check.

## elixir_version/0

Returns the required Elixir version for the check.

## exit_status/0

Returns the exit status for the check.

## explanations/0

Returns the explanations for the check and params as a keyword list.

## id/0

Returns an ID that can be used to identify the check.

## param_defaults/0

Returns the default values for the check's params as a keyword list.

## run_on_all?/0

Returns whether or not this check runs on all source files.

## run_on_all_source_files/3

Runs the current check on all `source_files` by calling `run_on_source_file/3`.

If you are developing a check that has to run on all source files, you can overwrite `run_on_all_source_files/3`:

    defmodule MyCheck do
      use Credo.Check

      def run_on_all_source_files(exec, source_files, params) do
        issues =
          source_files
          |> do_something_crazy()
          |> do_something_crazier()

        append_issues_and_timings(issues, exec)

        :ok
      end
    end

Check out Credo's checks from the consistency category for examples of these kinds of checks.

## run_on_source_file/3

Runs the current check on a single `source_file` and appends the resulting issues to the current `exec`.

## tags/0

Returns the tags for the check.