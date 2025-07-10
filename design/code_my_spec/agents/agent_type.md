# Overview

Simple struct defining agent types.

```elixir
defmodule AgentType do
  @enforce_keys [:name, :description, :prompt]
  defstruct [additional_tools: [], :name, :implementation, :prompt, :description, :config]
end
```