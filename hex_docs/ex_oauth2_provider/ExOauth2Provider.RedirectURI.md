# ExOauth2Provider.RedirectURI

Functions for dealing with redirect uri.

## validate/2

Validates if a url can be used as a redirect_uri.

Validates according to [RFC 6749 3.1.2](https://tools.ietf.org/html/rfc6749#section-3.1.2)
and [RFC 8252 7.1](https://tools.ietf.org/html/rfc8252#section-7.1). The validation is
skipped if the redirect uri is the same as the `:native_redirect_uri` configuration
setting.

## matches?/3

Check if uri matches client uri

## valid_for_authorization?/3

Check if a url matches a client redirect_uri

## native_redirect_uri?/2

Check if a url is native

## uri_with_query/2

Adds query parameters to uri