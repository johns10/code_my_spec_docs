# Earmark.Restructure



## split_by_regex/3

Utility for creating a restructuring that parses text by splitting it into
parts "of interest" vs. "other parts" using a regular expression.
Returns a list of parts where the parts matching regex have been processed
by invoking map_captures_fn on each part, and a list of remaining parts,
preserving the order of parts from what it was in the plain text item.

      iex(2)> input = "This is ::all caps::, right?"
      ...(2)> split_by_regex(input, ~r/::(.*?)::/, fn [_, inner|_] -> String.upcase(inner) end)
      ["This is ", "ALL CAPS", ", right?"]

## merge_lists/3

Given two lists that are either of equal length, or with the first list
exactly one element longer than the second, returns a list that begins with
the first element from the first list, then the first element from the second
list, and so forth until both lists are empty.