# OAuth2.Serializer

A serializer is responsible for encoding/decoding request/response bodies.

## Example

    defmodule MyApp.JSON do
      def encode!(data), do: Jason.encode!(data)
      def decode!(binary), do: Jason.decode!(binary)
    end