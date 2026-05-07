# ExOauth2Provider.RedirectURI

Functions for dealing with redirect uri.

## matches?(uri, client_uri, config)

Check if uri matches client uri

## native_redirect_uri?(url, config)

Check if a url is native

## uri_with_query(uri, query)

Adds query parameters to uri

## valid_for_authorization?(url, client_url, config)

Check if a url matches a client redirect_uri

## validate(url, config)

Validates if a url can be used as a redirect_uri.

Validates according to [RFC 6749 3.1.2](https://tools.ietf.org/html/rfc6749#section-3.1.2)
and [RFC 8252 7.1](https://tools.ietf.org/html/rfc8252#section-7.1). The validation is
skipped if the redirect uri is the same as the `:native_redirect_uri` configuration
setting.