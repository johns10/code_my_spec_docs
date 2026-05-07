# OAuth2.Request



## request(method, client, url, body, headers, opts)

Makes a request of given type to the given URL using the `OAuth2.AccessToken`.

## request!(method, client, url, body, headers, opts)

Same as `request/6` but returns `OAuth2.Response` or raises an error if an
error occurs during the request.

An `OAuth2.Error` exception is raised if the request results in an
error tuple (`{:error, reason}`).