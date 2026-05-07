# Dotenvy.Error

This error module can be useful when writing your own custom conversion
functions because special contextual information will be included with any
errors.

## Examples

Let's say your configuration needs to supply one of a set of possible values
(i.e. an enum). We can define a custom function to support this and pass it
as the second argument to `Dotenvy.env!/2`

    # runtime.exs
    import Config
    import Dotenvy

    size_enum = fn
      "large" -> :large
      "small" -> :small
      _ ->
        raise Dotenvy.Error, message: "allowed size_enum values are large or small"
    end

    config :myapp, :some_bool, env!("SIZE", size_enum)