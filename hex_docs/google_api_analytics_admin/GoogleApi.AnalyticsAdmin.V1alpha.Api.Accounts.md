# GoogleApi.AnalyticsAdmin.V1alpha.Api.Accounts

API calls for all endpoints tagged `Accounts`.

## analyticsadmin_accounts_access_bindings_batch_create(connection, parent, optional_params \\ [], opts \\ [])

Creates information about multiple access bindings to an account or property. This method is transactional. If any AccessBinding cannot be created, none of the AccessBindings will be created.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Connection.t`) - Connection to server
*   `parent` (*type:* `String.t`) - Required. The account or property that owns the access bindings. The parent field in the CreateAccessBindingRequest messages must either be empty or match this field. Formats: - accounts/{account} - properties/{property}
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
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaBatchCreateAccessBindingsRequest.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaBatchCreateAccessBindingsResponse{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_accounts_access_bindings_batch_delete(connection, parent, optional_params \\ [], opts \\ [])

Deletes information about multiple users' links to an account or property.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Connection.t`) - Connection to server
*   `parent` (*type:* `String.t`) - Required. The account or property that owns the access bindings. The parent of all provided values for the 'names' field in DeleteAccessBindingRequest messages must match this field. Formats: - accounts/{account} - properties/{property}
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
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaBatchDeleteAccessBindingsRequest.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleProtobufEmpty{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_accounts_access_bindings_batch_get(connection, parent, optional_params \\ [], opts \\ [])

Gets information about multiple access bindings to an account or property.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Connection.t`) - Connection to server
*   `parent` (*type:* `String.t`) - Required. The account or property that owns the access bindings. The parent of all provided values for the 'names' field must match this field. Formats: - accounts/{account} - properties/{property}
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
    *   `:names` (*type:* `list(String.t)`) - Required. The names of the access bindings to retrieve. A maximum of 1000 access bindings can be retrieved in a batch. Formats: - accounts/{account}/accessBindings/{accessBinding} - properties/{property}/accessBindings/{accessBinding}
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaBatchGetAccessBindingsResponse{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_accounts_access_bindings_batch_update(connection, parent, optional_params \\ [], opts \\ [])

Updates information about multiple access bindings to an account or property.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Connection.t`) - Connection to server
*   `parent` (*type:* `String.t`) - Required. The account or property that owns the access bindings. The parent of all provided AccessBinding in UpdateAccessBindingRequest messages must match this field. Formats: - accounts/{account} - properties/{property}
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
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaBatchUpdateAccessBindingsRequest.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaBatchUpdateAccessBindingsResponse{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_accounts_access_bindings_create(connection, parent, optional_params \\ [], opts \\ [])

Creates an access binding on an account or property.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Connection.t`) - Connection to server
*   `parent` (*type:* `String.t`) - Required. Formats: - accounts/{account} - properties/{property}
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
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAccessBinding.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAccessBinding{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_accounts_access_bindings_delete(connection, name, optional_params \\ [], opts \\ [])

Deletes an access binding on an account or property.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Required. Formats: - accounts/{account}/accessBindings/{accessBinding} - properties/{property}/accessBindings/{accessBinding}
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
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleProtobufEmpty{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_accounts_access_bindings_get(connection, name, optional_params \\ [], opts \\ [])

Gets information about an access binding.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Required. The name of the access binding to retrieve. Formats: - accounts/{account}/accessBindings/{accessBinding} - properties/{property}/accessBindings/{accessBinding}
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
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAccessBinding{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_accounts_access_bindings_list(connection, parent, optional_params \\ [], opts \\ [])

Lists all access bindings on an account or property.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Connection.t`) - Connection to server
*   `parent` (*type:* `String.t`) - Required. Formats: - accounts/{account} - properties/{property}
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
    *   `:pageSize` (*type:* `integer()`) - The maximum number of access bindings to return. The service may return fewer than this value. If unspecified, at most 200 access bindings will be returned. The maximum value is 500; values above 500 will be coerced to 500.
    *   `:pageToken` (*type:* `String.t`) - A page token, received from a previous `ListAccessBindings` call. Provide this to retrieve the subsequent page. When paginating, all other parameters provided to `ListAccessBindings` must match the call that provided the page token.
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaListAccessBindingsResponse{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_accounts_access_bindings_patch(connection, name, optional_params \\ [], opts \\ [])

Updates an access binding on an account or property.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Output only. Resource name of this binding. Format: accounts/{account}/accessBindings/{access_binding} or properties/{property}/accessBindings/{access_binding} Example: "accounts/100/accessBindings/200"
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
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAccessBinding.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAccessBinding{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_accounts_delete(connection, name, optional_params \\ [], opts \\ [])

Marks target Account as soft-deleted (ie: "trashed") and returns it. This API does not have a method to restore soft-deleted accounts. However, they can be restored using the Trash Can UI. If the accounts are not restored before the expiration time, the account and all child resources (eg: Properties, GoogleAdsLinks, Streams, AccessBindings) will be permanently purged. https://support.google.com/analytics/answer/6154772 Returns an error if the target is not found.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Required. The name of the Account to soft-delete. Format: accounts/{account} Example: "accounts/100"
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
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleProtobufEmpty{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_accounts_get(connection, name, optional_params \\ [], opts \\ [])

Lookup for a single Account.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Required. The name of the account to lookup. Format: accounts/{account} Example: "accounts/100"
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
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAccount{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_accounts_get_data_sharing_settings(connection, name, optional_params \\ [], opts \\ [])

Get data sharing settings on an account. Data sharing settings are singletons.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Required. The name of the settings to lookup. Format: accounts/{account}/dataSharingSettings Example: `accounts/1000/dataSharingSettings`
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
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaDataSharingSettings{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_accounts_list(connection, optional_params \\ [], opts \\ [])

Returns all accounts accessible by the caller. Note that these accounts might not currently have GA properties. Soft-deleted (ie: "trashed") accounts are excluded by default. Returns an empty list if no relevant accounts are found.

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
    *   `:pageSize` (*type:* `integer()`) - The maximum number of resources to return. The service may return fewer than this value, even if there are additional pages. If unspecified, at most 50 resources will be returned. The maximum value is 200; (higher values will be coerced to the maximum)
    *   `:pageToken` (*type:* `String.t`) - A page token, received from a previous `ListAccounts` call. Provide this to retrieve the subsequent page. When paginating, all other parameters provided to `ListAccounts` must match the call that provided the page token.
    *   `:showDeleted` (*type:* `boolean()`) - Whether to include soft-deleted (ie: "trashed") Accounts in the results. Accounts can be inspected to determine whether they are deleted or not.
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaListAccountsResponse{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_accounts_patch(connection, name, optional_params \\ [], opts \\ [])

Updates an account.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Output only. Resource name of this account. Format: accounts/{account} Example: "accounts/100"
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
    *   `:updateMask` (*type:* `String.t`) - Required. The list of fields to be updated. Field names must be in snake case (for example, "field_to_update"). Omitted fields will not be updated. To replace the entire entity, use one path with the string "*" to match all fields.
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAccount.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAccount{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_accounts_provision_account_ticket(connection, optional_params \\ [], opts \\ [])

Requests a ticket for creating an account.

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
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaProvisionAccountTicketRequest.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaProvisionAccountTicketResponse{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_accounts_run_access_report(connection, entity, optional_params \\ [], opts \\ [])

Returns a customized report of data access records. The report provides records of each time a user reads Google Analytics reporting data. Access records are retained for up to 2 years. Data Access Reports can be requested for a property. Reports may be requested for any property, but dimensions that aren't related to quota can only be requested on Google Analytics 360 properties. This method is only available to Administrators. These data access records include GA UI Reporting, GA UI Explorations, GA Data API, and other products like Firebase & Admob that can retrieve data from Google Analytics through a linkage. These records don't include property configuration changes like adding a stream or changing a property's time zone. For configuration change history, see [searchChangeHistoryEvents](https://developers.google.com/analytics/devguides/config/admin/v1/rest/v1alpha/accounts/searchChangeHistoryEvents). To give your feedback on this API, complete the [Google Analytics Access Reports feedback](https://docs.google.com/forms/d/e/1FAIpQLSdmEBUrMzAEdiEKk5TV5dEHvDUZDRlgWYdQdAeSdtR4hVjEhw/viewform) form.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Connection.t`) - Connection to server
*   `entity` (*type:* `String.t`) - The Data Access Report supports requesting at the property level or account level. If requested at the account level, Data Access Reports include all access for all properties under that account. To request at the property level, entity should be for example 'properties/123' if "123" is your Google Analytics property ID. To request at the account level, entity should be for example 'accounts/1234' if "1234" is your Google Analytics Account ID.
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
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaRunAccessReportRequest.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaRunAccessReportResponse{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_accounts_search_change_history_events(connection, account, optional_params \\ [], opts \\ [])

Searches through all changes to an account or its children given the specified set of filters. Only returns the subset of changes supported by the API. The UI may return additional changes.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Connection.t`) - Connection to server
*   `account` (*type:* `String.t`) - Required. The account resource for which to return change history resources. Format: accounts/{account} Example: `accounts/100`
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
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaSearchChangeHistoryEventsRequest.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaSearchChangeHistoryEventsResponse{}}` on success
*   `{:error, info}` on failure