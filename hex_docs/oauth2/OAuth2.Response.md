# OAuth2.Response

Defines the `OAuth2.Response` struct which is created from the HTTP responses
made by the `OAuth2.Client` module.

## Struct fields

* `status_code` - HTTP response status code
* `headers` - HTTP response headers
* `body` - Parsed HTTP response body (based on "content-type" header)