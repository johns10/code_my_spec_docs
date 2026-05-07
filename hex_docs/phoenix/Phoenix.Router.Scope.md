# Phoenix.Router.Scope



## expand_alias(module, alias)

Expands the alias in the current router scope.

## full_path(module, path)

Returns the full path in the current router scope.

## init(module)

Initializes the scope.

## pipe_through(module, new_pipes)

Appends the given pipes to the current scope pipe through.

## pipeline(module, pipe)

Defines the given pipeline.

## pop(module)

Pops a scope from the module stack.

## push(module, path)

Pushes a scope into the module stack.

## route(line, module, kind, verb, path, plug, plug_opts, opts)

Builds a route based on the top of the stack.

## validate_path(path)

Validates a path is a string and contains a leading prefix.