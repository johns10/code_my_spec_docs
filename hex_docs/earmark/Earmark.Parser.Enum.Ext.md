# Earmark.Parser.Enum.Ext

Some extensions of Enum functions

## reduce_with_end(collection, initial_acc, reducer_fn)

`reduce_with_end` is like `Enum.reduce` for lists, but the reducer function is called for
each element of the list with the tuple `{:element, element}` and the accumulator and once
more at the end with `:end` and the accumulator

    iex(1)> reducer =
    ...(1)>   fn {:element, nil}, {partial, result} -> {[], [Enum.sum(partial)|result]}
    ...(1)>      {:element, val}, {partial, result} -> {[val|partial], result}
    ...(1)>      :end,            {partial, result} -> [Enum.sum(partial)|result] |> Enum.reverse
    ...(1)>   end
    ...(1)> [1, 2, nil, 4, 1, 0, nil, 3, 2, 2]
    ...(1)> |> reduce_with_end({[], []}, reducer)
    [3, 5, 7]

**N.B.** that in the treatment of `:end` we can change the shape of the accumulator w/o any
penalty concerning the complexity of the reducer function

## reverse_map_reduce(list, initial, fun)

Like map_reduce but reversing the list

    iex(2)> replace_nil_and_count = fn ele, acc ->
    ...(2)>   if ele, do: {ele, acc}, else: {"", acc + 1}
    ...(2)> end
    ...(2)> ["y", nil, "u", nil, nil, "a", nil] |> reverse_map_reduce(0, replace_nil_and_count)
    { ["", "a", "", "", "u", "", "y"], 4 }