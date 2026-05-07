# Earmark.Transform

#### Structure Conserving Transformers

For the convenience of processing the output of `Earmark.Parser.as_ast` we expose two structure conserving
mappers.

##### `map_ast`

Traverses an AST using a mapper function.

The mapper function will be called for each node including text elements unless `map_ast` is called with
the third positional parameter `ignore_strings`, which is optional and defaults to `false`, set to `true`.

Depending on the return value of the mapper function the traversal will either

- `{new_tag, new_atts, ignored, new_meta}`

  just replace the `tag`, `attribute` and `meta` values of the current node with the values of the returned
  quadruple (ignoring `ignored` for facilitating nodes w/o transformation)
  and then descend into the **original** content of the node.


- `{:replace, node}`

  replaces the current node with `node` and does not descend anymore, but continues traversal on sibblings.


- {new_function, {new_tag, new_atts, ignored, new_meta}}

  just replace the `tag`, `attribute` and `meta` values of the current node with the values of the returned
  quadruple (ignoring `ignored` for facilitating nodes w/o transformation)
  and then descend into the **original** content of the node but with the mapper function `new_function`
  used for transformation of the AST.

  **N.B.** The original mapper function will be used for transforming the sibbling nodes though.

takes a function that will be called for each node of the AST, where a leaf node is either a quadruple
like `{"code", [{"class", "inline"}], ["some code"], %{}}` or a text leaf like `"some code"`

The result of the function call must be

- for nodes → as described above

- for strings → strings or nodes

As an example let us transform an ast to have symbol keys

      iex(1)> input = [
      ...(1)> {"h1", [], ["Hello"], %{title: true}},
      ...(1)> {"ul", [], [{"li", [], ["alpha"], %{}}, {"li", [], ["beta"], %{}}], %{}}]
      ...(1)> map_ast(input, fn {t, a, _, m} -> {String.to_atom(t), a, nil, m} end, true)
      [ {:h1, [], ["Hello"], %{title: true}},
        {:ul, [], [{:li, [], ["alpha"], %{}}, {:li, [], ["beta"], %{}}], %{}} ]

**N.B.** If this returning convention is not respected `map_ast` might not complain, but the resulting
transformation might not be suitable for `Earmark.Transform.transform` anymore. From this follows that
any function passed in as value of the `postprocessor:` option must obey to these conventions.

##### `map_ast_with`

this is like `map_ast` but like a reducer an accumulator can also be passed through.

For that reason the function is called with two arguments, the first element being the same value
as in `map_ast` and the second the accumulator. The return values need to be equally augmented
tuples.

A simple example, annotating traversal order in the meta map's `:count` key, as we are not
interested in text nodes we use the fourth parameter `ignore_strings` which defaults to `false`

       iex(2)>  input = [
       ...(2)>  {"ul", [], [{"li", [], ["one"], %{}}, {"li", [], ["two"], %{}}], %{}},
       ...(2)>  {"p", [], ["hello"], %{}}]
       ...(2)>  counter = fn {t, a, _, m}, c -> {{t, a, nil, Map.put(m, :count, c)}, c+1} end
       ...(2)>  map_ast_with(input, 0, counter, true)
       {[ {"ul", [], [{"li", [], ["one"], %{count: 1}}, {"li", [], ["two"], %{count: 2}}], %{count: 0}},
         {"p", [], ["hello"], %{count: 3}}], 4}

Let us describe an implementation of a real world use case taken from [Elixir Forum](https://elixirforum.com/t/how-to-extend-earmark/47406)

Simplifying the exact parsing of the text node in this example we only want to replace a text node of the form `#elixir` with
a link to the Elixir home page _but_ only when inside a `{"p",....}` node

We can achieve this as follows

      iex(3)> elixir_home = {"a", [{"href", "https://elixir-lang.org"}], ["Elixir"], %{}}
      ...(3)> transformer = fn {"p", atts, _, meta}, _ -> {{"p", atts, nil, meta}, true}
      ...(3)>                  "#elixir", true -> {elixir_home, false}
      ...(3)>                  text, _ when is_binary(text) -> {text, false}
      ...(3)>                  node, _ ->  {node, false} end
      ...(3)> ast = [
      ...(3)>  {"p", [],[ "#elixir"], %{}}, {"bold", [],[ "#elixir"], %{}},
      ...(3)>  {"ol", [], [{"li", [],[ "#elixir"], %{}}, {"p", [],[ "elixir"], %{}}, {"p", [], ["#elixir"], %{}}], %{}}
      ...(3)> ]
      ...(3)> map_ast_with(ast, false, transformer)
      {[
       {"p", [],[{"a", [{"href", "https://elixir-lang.org"}], ["Elixir"], %{}}], %{}}, {"bold", [],[ "#elixir"], %{}},
       {"ol", [], [{"li", [],[ "#elixir"], %{}}, {"p", [],[ "elixir"], %{}}, {"p", [], [{"a", [{"href", "https://elixir-lang.org"}], ["Elixir"], %{}}], %{}}], %{}}
      ], false}

An alternate, maybe more elegant solution would be to change the mapper function during AST traversal
as demonstrated [here](https://github.com/pragdave/earmark/blob/master/test/acceptance/transform/map_ast_with_fnchange_test.exs)

#### Postprocessors and Convenience Functions

These can be declared in the fields `postprocessor` and `registered_processors` in the `Options` struct,
`postprocessor` is prepened to `registered_processors` and they are all applied to non string nodes (that
is the quadtuples of the AST which are of the form `{tag, atts, content, meta}`

All postprocessors can just be functions on nodes or a `TagSpecificProcessors` struct which will group
function applications depending on tags, as a convienience tuples of the form `{tag, function}` will be
transformed into a `TagSpecificProcessors` struct.

    iex(4)> add_class1 = &Earmark.AstTools.merge_atts_in_node(&1, class: "class1")
    ...(4)> m1 = Earmark.Options.make_options!(postprocessor: add_class1) |> make_postprocessor()
    ...(4)> m1.({"a", [], nil, nil})
    {"a", [{"class", "class1"}], nil, nil}

We can also use the `registered_processors` field:

    iex(5)> add_class1 = &Earmark.AstTools.merge_atts_in_node(&1, class: "class1")
    ...(5)> m2 = Earmark.Options.make_options!(registered_processors: add_class1) |> make_postprocessor()
    ...(5)> m2.({"a", [], nil, nil})
    {"a", [{"class", "class1"}], nil, nil}

Knowing that values on the same attributes are added onto the front the following doctest demonstrates
the order in which the processors are executed

    iex(6)> add_class1 = &Earmark.AstTools.merge_atts_in_node(&1, class: "class1")
    ...(6)> add_class2 = &Earmark.AstTools.merge_atts_in_node(&1, class: "class2")
    ...(6)> add_class3 = &Earmark.AstTools.merge_atts_in_node(&1, class: "class3")
    ...(6)> m = Earmark.Options.make_options!(postprocessor: add_class1, registered_processors: [add_class2, {"a", add_class3}])
    ...(6)> |> make_postprocessor()
    ...(6)> [{"a", [{"class", "link"}], nil, nil}, {"b", [], nil, nil}]
    ...(6)> |> Enum.map(m)
    [{"a", [{"class", "class3 class2 class1 link"}], nil, nil}, {"b", [{"class", "class2 class1"}], nil, nil}]

We can see that the tuple form has been transformed into a tag specific transformation **only** as a matter of fact, the explicit definition would be:

    iex(7)> m = make_postprocessor(
    ...(7)>   %Earmark.Options{
    ...(7)>     registered_processors:
    ...(7)>       [Earmark.TagSpecificProcessors.new({"a", &Earmark.AstTools.merge_atts_in_node(&1, target: "_blank")})]})
    ...(7)> [{"a", [{"href", "url"}], nil, nil}, {"b", [], nil, nil}]
    ...(7)> |> Enum.map(m)
    [{"a", [{"href", "url"}, {"target", "_blank"}], nil, nil}, {"b", [], nil, nil}]

We can also define a tag specific transformer in one step, which might (or might not) solve potential performance issues
when running too many processors

    iex(8)> add_class4 = &Earmark.AstTools.merge_atts_in_node(&1, class: "class4")
    ...(8)> add_class5 = &Earmark.AstTools.merge_atts_in_node(&1, class: "class5")
    ...(8)> add_class6 = &Earmark.AstTools.merge_atts_in_node(&1, class: "class6")
    ...(8)> tsp = Earmark.TagSpecificProcessors.new([{"a", add_class5}, {"b", add_class5}])
    ...(8)> m = Earmark.Options.make_options!(
    ...(8)>       postprocessor: add_class4,
    ...(8)>       registered_processors: [tsp, add_class6])
    ...(8)> |> make_postprocessor()
    ...(8)> [{"a", [], nil, nil}, {"c", [], nil, nil}, {"b", [], nil, nil}]
    ...(8)> |> Enum.map(m)
    [{"a", [{"class", "class6 class5 class4"}], nil, nil}, {"c", [{"class", "class6 class4"}], nil, nil}, {"b", [{"class", "class6 class5 class4"}], nil, nil}]

Of course the mechanics shown above is hidden if all we want is to trigger the postprocessor chain in `Earmark.as_html`, here goes a typical
example

    iex(9)> add_target = fn node -> # This will only be applied to nodes as it will become a TagSpecificProcessors
    ...(9)>   if Regex.match?(~r{\.x\.com\z}, Earmark.AstTools.find_att_in_node(node, "href", "")), do:
    ...(9)>     Earmark.AstTools.merge_atts_in_node(node, target: "_blank"), else: node end
    ...(9)> options = [
    ...(9)> registered_processors: [{"a", add_target}, {"p", &Earmark.AstTools.merge_atts_in_node(&1, class: "example")}]]
    ...(9)> markdown = [
    ...(9)>   "http://hello.x.com",
    ...(9)>   "",
    ...(9)>   "[some](url)",
    ...(9)>  ]
    ...(9)> Earmark.as_html!(markdown, options)
    "<p class=\"example\">\n<a href=\"http://hello.x.com\" target=\"_blank\">http://hello.x.com</a></p>\n<p class=\"example\">\n<a href=\"url\">some</a></p>\n"

##### Use case: Modification of Link Attributes depending on the URL

This would be done as follows

```elixir
        Earmark.as_html!(markdown, registered_processors: {"a", my_function_that_is_invoked_only_with_a_nodes})
```

##### Use case: Modification of the AST according to Annotations

**N.B.** Annotation are an _experimental_ feature in 1.4.16-pre and are documented [here](https://github.com/RobertDober/earmark_parser/#annotations)

By annotating our markdown source we can then influence the rendering. In this example we will just
add some decoration

    iex(10)> markdown = [ "A joke %% smile", "", "Charming %% in_love" ]
    ...(10)> add_smiley = fn {_, _, _, meta} = quad, _acc ->
    ...(10)>                case Map.get(meta, :annotation) do
    ...(10)>                  "%% smile"   -> {quad, "\u1F601"}
    ...(10)>                  "%% in_love" -> {quad, "\u1F60d"}
    ...(10)>                  _            -> {quad, nil}
    ...(10)>                end
    ...(10)>                text, nil -> {text, nil}
    ...(10)>                text, ann -> {"#{text} #{ann}", nil}
    ...(10)>              end
    ...(10)> Earmark.as_ast!(markdown, annotations: "%%") |> Earmark.Transform.map_ast_with(nil, add_smiley) |> Earmark.transform
    "<p>\nA joke  ὠ1</p>\n<p>\nCharming  ὠd</p>\n"

#### Structure Modifying Transformers

For structure modifications a tree traversal is needed and no clear pattern of how to assist this task with
tools has emerged yet.

## map_ast(ast, fun, ignore_strings \\ false)

This is a structure conserving transformation

    iex(11)> {:ok, ast, _} = Earmark.Parser.as_ast("- one\n- two\n")
    ...(11)> map_ast(ast, &(&1))
    [{"ul", [], [{"li", [], ["one"], %{}}, {"li", [], ["two"], %{}}], %{}}]

A more useful transformation
    iex(12)> {:ok, ast, _} = Earmark.Parser.as_ast("- one\n- two\n")
    ...(12)> fun = fn {_, _, _, _}=n -> Earmark.AstTools.merge_atts_in_node(n, class: "private")
    ...(12)>           string      -> string end
    ...(12)> map_ast(ast, fun)
    [{"ul", [{"class", "private"}], [{"li", [{"class", "private"}], ["one"], %{}}, {"li", [{"class", "private"}], ["two"], %{}}], %{}}]

However the usage of the `ignore_strings` option renders the code much simpler

    iex(13)> {:ok, ast, _} = Earmark.Parser.as_ast("- one\n- two\n")
    ...(13)> map_ast(ast, &Earmark.AstTools.merge_atts_in_node(&1, class: "private"), true)
    [{"ul", [{"class", "private"}], [{"li", [{"class", "private"}], ["one"], %{}}, {"li", [{"class", "private"}], ["two"], %{}}], %{}}]

## map_ast_with(ast, value, fun, ignore_strings \\ false)

This too is a structure perserving transformation but a value is passed to the mapping function as an accumulator, and the mapping
function needs to return the new node and the accumulator as a tuple, here is a simple example

    iex(14)> {:ok, ast, _} = Earmark.Parser.as_ast("- 1\n\n2\n- 3\n")
    ...(14)> summer = fn {"li", _, [v], _}=n, s -> {v_, _} = Integer.parse(v); {n, s + v_}
    ...(14)>             n, s -> {n, s} end
    ...(14)> map_ast_with(ast, 0, summer, true)
    {[{"ul", [], [{"li", [], ["1"], %{}}], %{}}, {"p", [], ["2"], %{}}, {"ul", [], [{"li", [], ["3"], %{}}], %{}}], 4}

or summing all numbers

    iex(15)> {:ok, ast, _} = Earmark.Parser.as_ast("- 1\n\n2\n- 3\n")
    ...(15)> summer = fn {_, _, _, _}=n, s -> {n, s}
    ...(15)>             n, s -> {n_, _} = Integer.parse(n); {"*", s+n_} end
    ...(15)> map_ast_with(ast, 0, summer)
    {[{"ul", [], [{"li", [], ["*"], %{}}], %{}}, {"p", [], ["*"], %{}}, {"ul", [], [{"li", [], ["*"], %{}}], %{}}], 6}

## transform(ast, options \\ %{initial_indent: 0, indent: 2, compact_output: false})

Transforms an AST to html, also accepts the result of `map_ast_with` for convenience