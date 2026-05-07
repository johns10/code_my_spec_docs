# Phoenix.LiveDashboard.ReingoldTilford



## build(tree, fun)

Builds a ReingoldTilfolrd tree.

The given tree is in the shape `{value, [child]}`.
The function receives the value and returns the
node label. The label is used to compute its width.

## dimensions(nodes)

Returns the dimensions of a canvas to render all given
ReingoldTilford nodes.

## lines(node)

Returns the tree lines.

## nodes(node)

Returns all nodes in a ReingoldTilford tree.