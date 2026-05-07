# Tesla.Builder



## adapter(name, opts)

Choose adapter for your API client.

    defmodule ExampleApi do
      use Tesla

      # set adapter as module
      adapter Tesla.Adapter.Hackney

      # set adapter as anonymous function
      adapter fn env ->
        ...
        env
      end
    end

## plug(middleware, opts)

Attach middleware to your API client.

    defmodule ExampleApi do
      use Tesla

      # plug middleware module with options
      plug Tesla.Middleware.BaseUrl, "http://api.example.com"

      # or without options
      plug Tesla.Middleware.JSON

      # or a custom middleware
      plug MyProject.CustomMiddleware
    end