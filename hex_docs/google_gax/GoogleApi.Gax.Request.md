# GoogleApi.Gax.Request

This module is used to build an HTTP request

## library_version/2

Specify the library version when building a request

## Parameters

*   `request` (*type:* `GoogleApi.Gax.Request.t`) - Collected request options
*   `version` (*type:* `String`) - Library version

## Returns

*   `GoogleApi.Gax.Request.t`

## method/2

Specify the request method when building a request

## Parameters

*   `request` (*type:* `GoogleApi.Gax.Request.t`) - Collected request options
*   `m` (*type:* `String`) - Request method

## Returns

*   `GoogleApi.Gax.Request.t`

## url/3

Specify the request URL when building a request

## Parameters

*   `request` (*type:* `GoogleApi.Gax.Request.t`) - Collected request options
*   `u` (*type:* `String`) - Request URL

## Returns

*   `GoogleApi.Gax.Request.t`

## add_optional_params/3

Add optional parameters to the request

## Parameters

*   `request` (*type:* `GoogleApi.Gax.Request.t`) - Collected request options
*   `definitions` (*type:* `Map`) - Map of parameter name to parameter location
*   `options` (*type:* `keyword()`) - The provided optional parameters

## Returns

*   `GoogleApi.Gax.Request.t`

## add_param/4

Add optional parameters to the request

## Parameters

*   `request` (*type:* `GoogleApi.Gax.Request.t`) - Collected request options
*   `location` (*type:* `atom()`) - Where to put the parameter
*   `key` (*type:* `atom()`) - The name of the parameter
*   `value` (*type:* `any()`) - The value of the parameter

## Returns

*   `GoogleApi.Gax.Request.t`