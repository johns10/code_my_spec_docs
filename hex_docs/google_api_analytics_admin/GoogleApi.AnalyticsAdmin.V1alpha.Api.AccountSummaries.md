# GoogleApi.AnalyticsAdmin.V1alpha.Api.AccountSummaries

API calls for all endpoints tagged `AccountSummaries`.

## analyticsadmin_account_summaries_list(connection, optional_params \\ [], opts \\ [])

Returns summaries of all accounts accessible by the caller.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Connection.t`) - Connection to server
*   `optional_params` (*type:* `keyword()`) - Optional parameters
    *   `:"$.xgafv"` (*type:* `String.t`) - V1 error format.
    *   `:access_token` (*type:* `String.t`) - OAuth access token.
    *   `:alt` (*type:* `String.t`) - Data format for response.
    *   `:callback` (*type:* `String.t`) - JSONP
    *   `:fields` (*type:* `String.t`) - Selector specifying which fields to include in a partial response.
    *   `:key` (*type:* `String.t`) - API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
    *   `:oauth_token` (*type:* `String.t`) - OAuth 2.0 token for the current user.
    *   `:prettyPrint` (*type:* `boolean()`) - Returns response with indentations and line breaks.
    *   `:quotaUser` (*type:* `String.t`) - Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
    *   `:uploadType` (*type:* `String.t`) - Legacy upload protocol for media (e.g. "media", "multipart").
    *   `:upload_protocol` (*type:* `String.t`) - Upload protocol for media (e.g. "raw", "multipart").
    *   `:pageSize` (*type:* `integer()`) - The maximum number of AccountSummary resources to return. The service may return fewer than this value, even if there are additional pages. If unspecified, at most 50 resources will be returned. The maximum value is 200; (higher values will be coerced to the maximum)
    *   `:pageToken` (*type:* `String.t`) - A page token, received from a previous `ListAccountSummaries` call. Provide this to retrieve the subsequent page. When paginating, all other parameters provided to `ListAccountSummaries` must match the call that provided the page token.
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaListAccountSummariesResponse{}}` on success
*   `{:error, info}` on failure