# GoogleApi.Gax.Response

This module helps decode Tesla responses

## decode(env, opts \\ [])

Handle the response for a Tesla request

## Parameters

*   `response` (*type:* `{:ok, Tesla.Env.t} | {:error, reason}`) - The response object
*   `opts` (*type:* `keyword()`) - [optional] Optional parameters
    *   `:dataWrapped` (*type:* `boolean()`) - If true, the remove the wrapping "data" field. Defaults to false.
    *   `:decode` (*type:* `boolean()`) - If false, returns the entire reponse. Defaults to true.
    *   `:struct` (*type:* `module`)

## Returns

*   `{:ok, struct()}` on success
*   `{:error, Tesla.Env.t}` on failure