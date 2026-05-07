# Credo.Code.Module

This module provides helper functions to analyse modules, return the defined
functions or module attributes.

## aliases(ast)

Returns the list of aliases defined in a given module source code.

## attribute(ast, attr_name)

Reads an attribute from a module's `ast`

## def_arity(ast)

Returns the arity of the given function definition `ast`

## def_count(ast)

Returns the function/macro count for the given module's AST

## def_name(arg1)

Returns the name of the function/macro defined in the given `ast`

## def_name_with_op(ast)

Returns the {fun_name, op} tuple of the function/macro defined in the given `ast`

## def_names(ast)

Returns the name of the functions/macros for the given module's `ast`

## def_names_with_op(ast)

Returns the name of the functions/macros for the given module's `ast`

## def_names_with_op(ast, arity)

Returns the name of the functions/macros for the given module's `ast` if it has the given `arity`.

## modules(ast)

Returns the list of modules used in a given module source code.

## name(ast)

Returns the name of a module's given ast node.