# ExOauth2Provider.Mixin.Revocable



## filter_revoked(data)

Filter revoked data.

## Examples

    iex> filter_revoked(%Data{revoked_at: nil, ...}}
    %Data{}

    iex> filter_revoked(%Data{revoked_at: ~N[2017-04-04 19:21:22.292762], ...}}
    nil

## is_revoked?(arg1)

Checks if data has been revoked.

## Examples

    iex> is_revoked?(%Data{revoked_at: nil, ...}}
    false

    iex> is_revoked?(%Data{revoked_at: ~N[2017-04-04 19:21:22.292762], ...}}
    true

## revoke(data, config \\ [])

Revoke data.

## Examples

    iex> revoke(data)
    {:ok, %Data{revoked_at: ~N[2017-04-04 19:21:22.292762], ...}}

    iex> revoke(invalid_data)
    {:error, %Ecto.Changeset{}}

## revoke!(data, config \\ [])

Same as `revoke/1` but raises error.