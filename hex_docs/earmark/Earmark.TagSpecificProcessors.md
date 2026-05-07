# Earmark.TagSpecificProcessors

This struct represents a list of tuples `{tag, function}` from which a postprocessing function
can be constructed

General Usage Examples:

    iex(0)> tsp = new({"p", &Earmark.AstTools.merge_atts_in_node(&1, class: "one")})
    ...(0)> tsp = prepend_tag_function(tsp, "i", &Earmark.AstTools.merge_atts_in_node(&1, class: "two"))
    ...(0)> make_postprocessor(tsp).({"p", [], nil, nil})
    {"p", [{"class", "one"}], nil, nil}

    iex(1)> tsp = new({"p", &Earmark.AstTools.merge_atts_in_node(&1, class: "one")})
    ...(1)> tsp = prepend_tag_function(tsp, "i", &Earmark.AstTools.merge_atts_in_node(&1, class: "two"))
    ...(1)> make_postprocessor(tsp).({"i", [{"class", "i"}], nil, nil})
    {"i", [{"class", "two i"}], nil, nil}

    iex(2)> tsp = new({"p", &Earmark.AstTools.merge_atts_in_node(&1, class: "one")})
    ...(2)> tsp = prepend_tag_function(tsp, "i", &Earmark.AstTools.merge_atts_in_node(&1, class: "two"))
    ...(2)> make_postprocessor(tsp).({"x", [], nil, nil})
    {"x", [], nil, nil}

## make_postprocessor(tag_specific_processors)

Constructs a postprocessor function from this struct which will find the function associated
to the tag of the node, and apply the node to it if such a function was found.

## new()

Convenience construction

    iex(3)> new()
    %Earmark.TagSpecificProcessors{}

## prepend_tag_function(tsp, tag, function)

Prepends a tuple {tag, function} to the list of such tuples.