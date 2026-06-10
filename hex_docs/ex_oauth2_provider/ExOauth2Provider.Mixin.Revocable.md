# ExOauth2Provider.Mixin.Revocable



## revoke/2

Revoke data.

## Examples

    iex> revoke(data)
    {:ok, %Data{revoked_at: ~N[2017-04-04 19:21:22.292762], ...}}

    iex> revoke(invalid_data)
    {:error, %Ecto.Changeset{}}

## revoke!/2

Same as `revoke/1` but raises error.

## filter_revoked/1

Filter revoked data.

## Examples

    iex> filter_revoked(%Data{revoked_at: nil, ...}}
    %Data{}

    iex> filter_revoked(%Data{revoked_at: ~N[2017-04-04 19:21:22.292762], ...}}
    nil

## is_revoked?/1

Checks if data has been revoked.

## Examples

    iex> is_revoked?(%Data{revoked_at: nil, ...}}
    false

    iex> is_revoked?(%Data{revoked_at: ~N[2017-04-04 19:21:22.292762], ...}}
    true