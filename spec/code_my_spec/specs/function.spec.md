# CodeMySpec.Specs.Function

Embedded schema representing a function from a spec.

**Fields**:

| Field           | Type     | Required | Description                             |
| --------------- | -------- | -------- | --------------------------------------- |
| name            | string   | Yes      | Function name with arity (e.g. build/1) |
| description     | string   | No       | What the function does                  |
| spec            | string   | No       | Elixir @spec declaration                |
| process         | string   | No       | Step-by-step process description        |
| test_assertions | [string] | No       | List of test assertions                 |
