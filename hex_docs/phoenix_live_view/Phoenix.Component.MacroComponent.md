# Phoenix.Component.MacroComponent



## ast_to_string(ast, opts \\ [])

Turns an AST into a string.

## Options

  * `attributes_encoder` - a custom function to encode attributes to iodata.
     Defaults to an HTML-safe encoder.

## get_data(component_module, macro_component)

Returns the stored data from macro components that returned `{:ok, ast, data}`.

As one macro component can be used multiple times in one module, the result is a list of all data values.

If the component module does not have any macro components defined, an empty list is returned.