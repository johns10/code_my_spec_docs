# Mix.Tasks.Compile.Spex

Compiles `.exs` files matching a glob pattern and returns their diagnostics.

Add `:spex` to your project's compilers list so it runs as part of `mix compile`:

    def project do
      [
        compilers: Mix.compilers() ++ [:spex],
        ...
      ]
    end

## Project configuration

Configure the glob pattern under the `:spex` key:

    def project do
      [
        spex: [pattern: "test/spex/**/*_spex.exs"],
        ...
      ]
    end

## Flags

  * `--spex-pattern` (`-p`) - glob pattern for .exs files to compile