# GoogleApi.Gax.Request

This module is used to build an HTTP request

## add_optional_params(request, definitions, list)

Add optional parameters to the request

## Parameters

*   `request` (*type:* `GoogleApi.Gax.Request.t`) - Collected request options
*   `definitions` (*type:* `Map`) - Map of parameter name to parameter location
*   `options` (*type:* `keyword()`) - The provided optional parameters

## Returns

*   `GoogleApi.Gax.Request.t`

## add_param(request, location, key, values)

Add optional parameters to the request

## Parameters

*   `request` (*type:* `GoogleApi.Gax.Request.t`) - Collected request options
*   `location` (*type:* `atom()`) - Where to put the parameter
*   `key` (*type:* `atom()`) - The name of the parameter
*   `value` (*type:* `any()`) - The value of the parameter

## Returns

*   `GoogleApi.Gax.Request.t`

## library_version(request, version)

Specify the library version when building a request

## Parameters

*   `request` (*type:* `GoogleApi.Gax.Request.t`) - Collected request options
*   `version` (*type:* `String`) - Library version

## Returns

*   `GoogleApi.Gax.Request.t`

## method(request, m)

Specify the request method when building a request

## Parameters

*   `request` (*type:* `GoogleApi.Gax.Request.t`) - Collected request options
*   `m` (*type:* `String`) - Request method

## Returns

*   `GoogleApi.Gax.Request.t`

## url(request, u, replacements)

Specify the request URL when building a request

## Parameters

*   `request` (*type:* `GoogleApi.Gax.Request.t`) - Collected request options
*   `u` (*type:* `String`) - Request URL

## Returns

*   `GoogleApi.Gax.Request.t`