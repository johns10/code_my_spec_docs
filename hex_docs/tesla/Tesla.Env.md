# Tesla.Env

This module defines a `t:Tesla.Env.t/0` struct that stores all data related to request/response.

## Fields

- `:method` - method of request. Example: `:get`
- `:url` - request url. Example: `"https://www.google.com"`
- `:query` - list of query params.
  Example: `[{"param", "value"}]` will be translated to `?params=value`.
  Note: query params passed in url (e.g. `"/get?param=value"`) are not parsed to `query` field.
- `:headers` - list of request/response headers.
  Example: `[{"content-type", "application/json"}]`.
  Note: request headers are overridden by response headers when adapter is called.
- `:body` - request/response body.
  Note: request body is overridden by response body when adapter is called.
- `:status` - response status. Example: `200`
- `:opts` - list of options. Example: `[adapter: [recv_timeout: 30_000]]`