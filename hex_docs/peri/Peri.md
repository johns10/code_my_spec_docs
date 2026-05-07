# Peri

Peri is a schema validation library for Elixir, inspired by Clojure's Plumatic Schema.
It provides a flexible and powerful way to define and validate data structures using schemas.
The library supports nested schemas, optional fields, custom validation functions, and various type constraints.

## Key Features

- **Simple and Nested Schemas**: Define schemas that can handle complex, nested data structures.
- **Optional and Required Fields**: Specify fields as optional or required with type constraints.
- **Custom Validation Functions**: Use custom functions to validate fields.
- **Comprehensive Error Handling**: Provides detailed error messages for validation failures.
- **Type Constraints**: Supports various types including enums, lists, maps, tuples, literals, and more.

## Usage

To define a schema, use the `defschema` macro. By default, all fields in the schema are optional unless specified otherwise.

```elixir
defmodule MySchemas do
  import Peri

  defschema :user, %{
    name: :string,
    age: :integer,
    email: {:required, :string},
    address: %{
      street: :string,
      city: :string
    },
    tags: {:list, :string},
    role: {:enum, [:admin, :user, :guest]},
    geolocation: {:tuple, [:float, :float]},
    preferences: {:map, :string},
    scores: {:map, :string, :integer},
    status: {:literal, :active},
    rating: {:custom, &validate_rating/1}
  }

  defp validate_rating(n) when n < 10, do: :ok
  defp validate_rating(_), do: {:error, "invalid rating", []}
end
```

You can then use the schema to validate data:

```elixir
user_data = %{
  name: "John", age: 30, email: "john@example.com",
  address: %{street: "123 Main St", city: "Somewhere"},
  tags: ["science", "funky"], role: :admin,
  geolocation: {12.2, 34.2},
  preferences: %{"theme" => "dark", "notifications" => "enabled"},
  scores: %{"math" => 95, "science" => 92},
  status: :active,
  rating: 9
}

case MySchemas.user(user_data) do
  {:ok, valid_data} -> IO.puts("Data is valid!")
  {:error, errors} -> IO.inspect(errors, label: "Validation errors")
end
```

## Error Handling

Peri provides detailed error messages that include the path to the invalid data, the expected and actual values, and custom error messages for custom validations.

## Schema Types

Peri supports the following schema types:

- `:string`, `:integer`, `:float`, `:boolean`, `:atom`, `:map`, `:pid` - Basic types
- `{:required, type}` - Mark a field as required
- `{:list, type}` - List of elements of the given type
- `{:map, type}` - Map with values of the given type
- `{:map, key_type, value_type}` - Map with keys and values of specified types
- `{:schema, schema}` - Explicitly tagged nested schema
- `{:schema, map_schema, {:additional_keys, type}}` - Nested schema map, with extra entries validated using another type
- `{:tuple, [type1, type2, ...]}` - Tuple with elements of specified types
- `{:enum, [value1, value2, ...]}` - One of the specified values
- `{:literal, value}` - Exactly matches the specified value
- `{:either, {type1, type2}}` - Either type1 or type2
- `{:oneof, [type1, type2, ...]}` - One of the specified types
- `{:cond, condition, true_type, false_type}` - Conditional validation based on callback
- `{:dependent, callback}` - Dynamic type based on callback result
- Nested maps for complex structures

## Callback Functions for :cond and :dependent

Both `:cond` and `:dependent` types support 1-arity and 2-arity callbacks:

- **1-arity callbacks** receive the root data structure (backward compatible)
- **2-arity callbacks** receive `(current, root)` where:
  - `current` is the data at the current validation context (e.g., list element)
  - `root` is the entire root data structure

This is especially useful when validating elements within lists:

```elixir
defschema :parent, %{
  items: {:list, %{
    type: :string,
    value: {:dependent, fn current, _root ->
      case current.type do
        "number" -> {:ok, :integer}
        "text" -> {:ok, :string}
        _ -> {:ok, :any}
      end
    end}
  }}
}
```

## Functions

- `validate/2` - Validates data against a schema.
- `conforms?/2` - Checks if data conforms to a schema.
- `validate_schema/1` - Validates the schema definition.
- `generate/1` - Generates sample data based on schema (when StreamData is available).

## Example

```elixir
defmodule MySchemas do
  import Peri

  defschema :user, %{
    name: :string,
    age: :integer,
    email: {:required, :string}
  }
end

user_data = %{name: "John", age: 30, email: "john@example.com"}
case MySchemas.user(user_data) do
  {:ok, valid_data} -> IO.puts("Data is valid!")
  {:error, errors} -> IO.inspect(errors, label: "Validation errors")
end
```

## conforms?(schema, data, opts \\ [])

Checks if the given data conforms to the specified schema.

## Parameters

  - `schema`: The schema definition to validate against.
  - `data`: The data to be validated.

## Options

  - `:mode` - Validation mode. Can be `:strict` (default) or `:permissive`.
    - `:strict` - Only fields defined in the schema are returned.
    - `:permissive` - All fields from the input data are preserved.

## Returns

  - `true` if the data conforms to the schema.
  - `false` if the data does not conform to the schema.

## Examples

    iex> schema = %{name: :string, age: :integer}
    iex> data = %{name: "Alice", age: 30}
    iex> Peri.conforms?(schema, data)
    true

    iex> invalid_data = %{name: "Alice", age: "thirty"}
    iex> Peri.conforms?(schema, invalid_data)
    false

## put_in_enum(enum, key, val)

Helper function to put a value into an enum, handling
not only maps and keyword lists but also structs.

## Examples

    iex> Peri.put_in_enum(%{}, :hello, "world")
    iex> Peri.put_in_enum(%{}, "hello", "world")
    iex> Peri.put_in_enum(%User{}, :hello, "world")
    iex> Peri.put_in_enum([], :hello, "world")

## to_changeset!(s, attrs)

Converts a `Peri.schema()` definition to an Ecto [schemaless changesets](https://hexdocs.pm/ecto/Ecto.Changeset.html#module-schemaless-changesets).

## validate(schema, data, opts \\ [])

Validates a given data map against a schema with options.

Returns `{:ok, data}` if the data is valid according to the schema, or `{:error, errors}` if there are validation errors.

## Parameters

  - schema: The schema definition map.
  - data: The data map to be validated.
  - opts: Options for validation.

## Options

  - `:mode` - Validation mode. Can be `:strict` (default) or `:permissive`.
    - `:strict` - Only fields defined in the schema are returned.
    - `:permissive` - All fields from the input data are preserved.

## Examples

    schema = %{name: :string, age: :integer}
    data = %{name: "John", age: 30, extra: "field"}

    # Strict mode (default)
    Peri.validate(schema, data)
    # => {:ok, %{name: "John", age: 30}}

    # Permissive mode
    Peri.validate(schema, data, mode: :permissive)
    # => {:ok, %{name: "John", age: 30, extra: "field"}}

## validate_schema(schema)

Validates a schema definition to ensure it adheres to the expected structure and types.

This function can handle both simple and complex schema definitions, including nested schemas, custom validation functions, and various type constraints.

## Parameters

  - `schema` - The schema definition to be validated. It can be a map or a keyword list representing the schema.

## Returns

  - `{:ok, schema}` - If the schema is valid, returns the original schema.
  - `{:error, errors}` - If the schema is invalid, returns an error tuple with detailed error information.

## Examples

  Validating a simple schema:

  ```elixir
  schema = %{
    name: :string,
    age: :integer,
    email: {:required, :string}
  }
  assert {:ok, ^schema} = validate_schema(schema)
  ```

  Validating a nested schema:

  ```elixir
  schema = %{
    user: %{
      name: :string,
      profile: %{
        age: {:required, :integer},
        email: {:required, :string}
      }
    }
  }
  assert {:ok, ^schema} = validate_schema(schema)
  ```

  Handling invalid schema definition:

  ```elixir
  schema = %{
    name: :str,
    age: :integer,
    email: {:required, :string}
  }
  assert {:error, _errors} = validate_schema(schema)
  ```

## defschema(name, schema, opts \\ [])

Defines a schema with a given name and schema definition.

## Examples

    defmodule MySchemas do
      import Peri

      defschema :user, %{
        name: :string,
        age: :integer,
        email: {:required, :string}
      }

      # With permissive mode
      defschema :flexible_user, %{
        name: :string,
        email: {:required, :string}
      }, mode: :permissive
    end

    user_data = %{name: "John", age: 30, email: "john@example.com"}
    MySchemas.user(user_data)
    # => {:ok, %{name: "John", age: 30, email: "john@example.com"}}

    invalid_data = %{name: "John", age: 30}
    MySchemas.user(invalid_data)
    # => {:error, [email: "is required"]}

    # Permissive mode preserves extra fields
    flexible_data = %{name: "John", email: "john@example.com", role: "admin"}
    MySchemas.flexible_user(flexible_data)
    # => {:ok, %{name: "John", email: "john@example.com", role: "admin"}}

## is_enumerable(data)

Checks if the given data is an enumerable, specifically a map or a list.

## Parameters

  - `data`: The data to check.

## Examples

    iex> is_enumerable(%{})
    true

    iex> is_enumerable([])
    true

    iex> is_enumerable(123)
    false

    iex> is_enumerable("string")
    false

## is_numeric(n)

Checks if the given data is a numeric value, specifically a integer or a float.

## Parameters

  - `data`: The data to check.

## Examples

    iex> is_numeric(123)
    true

    iex> is_numeric(0xFF)
    true

    iex> is_numeric(12.12)
    true

    iex> is_numeric("string")
    false

    iex> is_numeric(%{})
    false

## is_numeric_type(t)

Checks if the given type as an atom is a numeric (integer or float).

## Parameters

  - `data`: The data to check.

## Examples

    iex> is_numeric(:integer)
    true

    iex> is_numeric(:float)
    true

    iex> is_numeric(:list)
    false

    iex> is_numeric({:enum, _})
    false