# Credo.Code.Block

This module provides helper functions to analyse blocks, e.g. the block taken
by the `if` macro.

## after_block?(ast)

Returns true if the given `ast` has an after block.

## after_block_for(arguments)

Returns a tuple {:ok, after_block} or nil for a given AST node.

## after_block_for!(ast)

Returns the after: block of a given AST node.

## all_blocks_for!(ast)

Returns the do: block of a given AST node.

## calls_in_catch_block(arg)

Returns the children of the `catch` block of the given AST node.

## calls_in_do_block(arg)

Returns the children of the `do` block of the given AST node.

## calls_in_rescue_block(arg)

Returns the children of the `rescue` block of the given AST node.

## catch_block?(ast)

Returns true if the given `ast` has an catch block.

## catch_block_for(arguments)

Returns a tuple {:ok, catch_block} or nil for a given AST node.

## catch_block_for!(ast)

Returns the catch: block of a given AST node.

## do_block?(ast)

Returns true if the given `ast` has a do block.

## do_block_for(arguments)

Returns a tuple {:ok, do_block} or nil for a given AST node.

## do_block_for!(ast)

Returns the do: block of a given AST node.

## else_block?(ast)

Returns true if the given `ast` has an else block.

## else_block_for(arguments)

Returns a tuple {:ok, else_block} or nil for a given AST node.

## else_block_for!(ast)

Returns the `else` block of a given AST node.

## rescue_block?(ast)

Returns true if the given `ast` has an rescue block.

## rescue_block_for(arguments)

Returns a tuple {:ok, rescue_block} or nil for a given AST node.

## rescue_block_for!(ast)

Returns the rescue: block of a given AST node.