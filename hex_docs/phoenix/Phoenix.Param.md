# Phoenix.Param

A protocol that converts data structures into URL parameters.

This protocol is used by `Phoenix.VerifiedRoutes` and other parts of the
Phoenix stack. For example, when you write:

    ~p"/user/#{@user}/edit"

Phoenix knows how to extract the `:id` from `@user` thanks
to this protocol.

(Deprecated URL helpers, e.g. `user_path(conn, :edit, @user)`, work the
same way.)

By default, Phoenix implements this protocol for integers, binaries, atoms,
and structs. For structs, a key `:id` is assumed, but you may provide a
specific implementation.

The term `nil` cannot be converted to param.

## Custom parameters

In order to customize the parameter for any struct,
one can simply implement this protocol. For example for a `Date` struct:

    defimpl Phoenix.Param, for: Date do
      def to_param(date) do
        Date.to_string(date)
      end
    end

However, for convenience, this protocol can also be
derivable. For example:

    defmodule User do
      @derive Phoenix.Param
      defstruct [:id, :username]
    end

By default, the derived implementation will also use
the `:id` key. In case the user does not contain an
`:id` key, the key can be specified with an option:

    defmodule User do
      @derive {Phoenix.Param, key: :username}
      defstruct [:username]
    end

will automatically use `:username` in URLs.

When using Ecto, you must call `@derive` before
your `schema` call:

    @derive {Phoenix.Param, key: :username}
    schema "users" do

## t/0

All the types that implement this protocol.