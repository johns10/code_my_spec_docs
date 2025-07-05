# Overview

Simple struct defining agent types.

```elixir
defmodule AgentType do
  @enforce_keys [:description, :prompt]
  defstruct [additional_tools: [], :implementation, :prompt, :description, :config]
end
```