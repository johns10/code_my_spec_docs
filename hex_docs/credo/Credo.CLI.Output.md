# Credo.CLI.Output

This module provides helper functions regarding command line output.

## foreground_color(background_color)

Returns a suitable foreground color for a given `background_color`.

    iex> Credo.CLI.Output.foreground_color(:yellow)
    :black

    iex> Credo.CLI.Output.foreground_color(:blue)
    :white

## issue_color(issue_or_priority)

Returns a suitable color for a given priority.

    iex> Credo.CLI.Output.issue_color(%Credo.Issue{priority: :higher})
    :red

    iex> Credo.CLI.Output.issue_color(%Credo.Issue{priority: 20})
    :red

## priority_arrow(issue_or_priority)

Returns a suitable arrow for a given priority.

    iex> Credo.CLI.Output.priority_arrow(:high)
    "↗"

    iex> Credo.CLI.Output.priority_arrow(10)
    "↗"

    iex> Credo.CLI.Output.priority_arrow(%Credo.Issue{priority: 10})
    "↗"

## priority_name(issue_or_priority)

Returns a suitable name for a given priority.

    iex> Credo.CLI.Output.priority_name(:normal)
    "normal"

    iex> Credo.CLI.Output.priority_name(1)
    "normal"

    iex> Credo.CLI.Output.priority_name(%Credo.Issue{priority: 1})
    "normal"