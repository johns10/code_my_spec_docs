# ExOauth2Provider.Mixin.Expirable



## filter_expired(data)

Filter expired data.

## Examples

    iex> filter_expired(%Data{expires_in: 7200, inserted_at: ~N[2017-04-04 19:21:22.292762], ...}}
    %Data{}

    iex> filter_expired(%Data{expires_in: 10, inserted_at: ~N[2017-04-04 19:21:22.292762], ...}}
    nil

## is_expired?(arg1)

Checks if data has expired.

## Examples

    iex> is_expired?(%Data{expires_in: 7200, inserted_at: ~N[2017-04-04 19:21:22], ...}}
    false

    iex> is_expired?(%Data{expires_in: 10, inserted_at: ~N[2017-04-04 19:21:22], ...}}
    true

    iex> is_expired?(%Data{expires_in: nil}}
    false