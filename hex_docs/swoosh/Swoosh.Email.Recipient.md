# Swoosh.Email.Recipient

Recipient Protocol controls how data is formatted into an email recipient

## Deriving

The protocol allows leveraging the Elixir's `@derive` feature to simplify protocol implementation
in trivial cases. Accepted options are:

  * `:name` (optional)
  * `:address` (required)

## Example

    defmodule MyUser do
      @derive {Swoosh.Email.Recipient, name: :name, address: :email}
      defstruct [:name, :email, :other_props]
    end

or with optional name...

    defmodule MySubscriber do
      @derive {Swoosh.Email.Recipient, address: :email}
      defstruct [:email, :preferences]
    end

full implementation without deriving...

    defmodule MyUser do
      defstruct [:name, :email, :other_props]
    end

    defimpl Swoosh.Email.Recipient, for: MyUser do
      def format(%MyUser{name: name, email: address} = value) do
        {name, address}
      end
    end

## format(value)

Formats `value` into a Swoosh recipient, a 2-tuple with recipient name and recipient address

## format/1

Formats `value` into a Swoosh recipient, a 2-tuple with recipient name and recipient address