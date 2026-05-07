# Earmark.AstTools

Tools for AST manipulation

## find_att_in_node(node_or_atts, att)

Convenience function to access an attribute from an AST node or a list of attributes

    iex(4)> find_att_in_node({"a", [{"class", "link"}], [], %{}}, "class")
    "link"

    iex(5)> find_att_in_node({"a", [{"class", "link"}], [], %{}}, "target")
    nil

    iex(6)> find_att_in_node([{"class", "link"}], "class")
    "link"

    iex(7)> find_att_in_node([{"class", "link"}], "target")
    nil

## find_att_in_node(node_or_atts, att, default)

Convenience function to access an attribute from an AST node or a list of attributes with a default value.

    iex(8)> find_att_in_node({"a", [{"class", "link"}], [], %{}}, "target", :default)
    :default


    iex(9)> find_att_in_node([{"class", "link"}], "target", :default)
    :default

## merge_atts(attrs, new)

A helper to merge attributes in their cannonical representation


    iex(1)> merge_atts([{"href", "url"}], target: "_blank")
    [{"href", "url"}, {"target", "_blank"}]

    iex(2)> merge_atts([{"href", "url"}, {"target", "nonsense"}], %{"target" => "_blank"})
    [{"href", "url"}, {"target", "_blank nonsense"}]

    iex(3)>  merge_atts([{"href", "url"}, {"target", "nonsense"}, {"alt", "nowhere"}],
    ...(3)>              [{"target", "_blank"}, title: "where?"])
    [{"alt", "nowhere"}, {"href", "url"}, {"target", "_blank nonsense"}, {"title", "where?"}]

## merge_atts_in_node(arg, new_atts)

A convenience function that extracts the original attributes to be merged with new attributes
and puts the result into the node again

    iex(10)> merge_atts_in_node({"img", [{"src", "there"}, {"alt", "there"}], [], %{some: "meta"}}, alt: "here")
    {"img", [{"alt", "here there"}, {"src", "there"}], [], %{some: "meta"}}

## node_only_fn(fun)

Wrap a function that can only be called on nodes

    iex(11)> f = fn {t, _, _, _} -> t end
    ...(11)> f_ = node_only_fn(f)
    ...(11)> {f_.({"p", [], [], %{}}), f_.("text")}
    {"p", "text"}