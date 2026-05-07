# ExOauth2Provider.Scopes

Functions for dealing with scopes.

## all?(scopes, required_scopes)

Check if required scopes exists in the scopes list

## default_to_server_scopes(server_scopes, config)

Will default to server scopes if no scopes supplied

## equal?(scopes, other_scopes)

Check if two lists of scopes are equal

## filter_default_scopes(scopes, config)

Filter defaults scopes from scopes list

## from_access_token(access_token)

Fetch scopes from an access token

## to_list(str)

Convert scopes string to list

## to_string(scopes)

Convert scopes list to string