# Boundary.Mix.CompilerState



## add_module_meta(module, key, value)

Stores module meta.

The data is stored in memory, and later flushed to the manifest file.

## boundary_defs(app)

Returns an enumerable stream of cached raw boundary definitions

If no cache exists, `nil` is returned.

## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.

## protocol_impls(app)

Returns a mapset with all protocol implementation modules (define with `defimpl`) in the given app.

If no cache exists, `nil` is returned.

## references()

Returns a lazy stream where each element is of type `t:Boundary.ref()`