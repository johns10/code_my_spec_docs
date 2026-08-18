# CodeMySpec.Code

Reading Elixir source as data — what a file depends on, what it defines, what it
asserts.

One implementation sits behind this: `ElixirAst`, which parses a file (or a
string of source) to an AST and walks it. Everything here delegates to it.

Called by `StaticAnalysis` — never call `ElixirAst` directly. That is the same
arrangement `StaticAnalysis` states about `Pipeline`, and what every other
namespace in this tree does. `StaticAnalysis.SpecAlignment` reaches past this
module today and should stop when it next changes.

Both shapes of every extractor are exposed. A path is what an analyzer has when
it is walking a project; a string is what it has when the content came from
somewhere other than disk, which is why the `*_from_source/1` variants exist at
all — collapsing them would put a `File.write` in front of every in-memory call.

## Type

logic

## Delegates

- get_dependencies/1: Code.ElixirAst.get_dependencies/1
- get_public_functions/1: Code.ElixirAst.get_public_functions/1
- public_functions_from_source/1: Code.ElixirAst.public_functions_from_source/1
- get_test_assertions/1: Code.ElixirAst.get_test_assertions/1
- test_assertions_from_source/1: Code.ElixirAst.test_assertions_from_source/1

## Dependencies

- Code
