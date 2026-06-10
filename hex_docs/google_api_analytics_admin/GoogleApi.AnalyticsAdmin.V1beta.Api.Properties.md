# GoogleApi.AnalyticsAdmin.V1beta.Api.Properties

API calls for all endpoints tagged `Properties`.

## analyticsadmin_properties_acknowledge_user_data_collection/4

Acknowledges the terms of user data collection for the specified property. This acknowledgement must be completed (either in the Google Analytics UI or through this API) before MeasurementProtocolSecret resources may be created.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `property` (*type:* `String.t`) - Required. The property for which to acknowledge user data collection.
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
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaAcknowledgeUserDataCollectionRequest.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaAcknowledgeUserDataCollectionResponse{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_create/3

Creates a Google Analytics property with the specified location and attributes.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
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
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaProperty.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaProperty{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_delete/4

Marks target Property as soft-deleted (ie: "trashed") and returns it. This API does not have a method to restore soft-deleted properties. However, they can be restored using the Trash Can UI. If the properties are not restored before the expiration time, the Property and all child resources (eg: GoogleAdsLinks, Streams, AccessBindings) will be permanently purged. https://support.google.com/analytics/answer/6154772 Returns an error if the target is not found.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Required. The name of the Property to soft-delete. Format: properties/{property_id} Example: "properties/1000"
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

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaProperty{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_get/4

Lookup for a single GA Property.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Required. The name of the property to lookup. Format: properties/{property_id} Example: "properties/1000"
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

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaProperty{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_get_data_retention_settings/4

Returns the singleton data retention settings for this property.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Required. The name of the settings to lookup. Format: properties/{property}/dataRetentionSettings Example: "properties/1000/dataRetentionSettings"
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

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaDataRetentionSettings{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_list/3

Returns child Properties under the specified parent Account. Properties will be excluded if the caller does not have access. Soft-deleted (ie: "trashed") properties are excluded by default. Returns an empty list if no relevant properties are found.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
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
    *   `:filter` (*type:* `String.t`) - Required. An expression for filtering the results of the request. Fields eligible for filtering are: `parent:`(The resource name of the parent account/property) or `ancestor:`(The resource name of the parent account) or `firebase_project:`(The id or number of the linked firebase project). Some examples of filters: ``` | Filter | Description | |-----------------------------|-------------------------------------------| | parent:accounts/123 | The account with account id: 123. | | parent:properties/123 | The property with property id: 123. | | ancestor:accounts/123 | The account with account id: 123. | | firebase_project:project-id | The firebase project with id: project-id. | | firebase_project:123 | The firebase project with number: 123. | ```
    *   `:pageSize` (*type:* `integer()`) - The maximum number of resources to return. The service may return fewer than this value, even if there are additional pages. If unspecified, at most 50 resources will be returned. The maximum value is 200; (higher values will be coerced to the maximum)
    *   `:pageToken` (*type:* `String.t`) - A page token, received from a previous `ListProperties` call. Provide this to retrieve the subsequent page. When paginating, all other parameters provided to `ListProperties` must match the call that provided the page token.
    *   `:showDeleted` (*type:* `boolean()`) - Whether to include soft-deleted (ie: "trashed") Properties in the results. Properties can be inspected to determine whether they are deleted or not.
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaListPropertiesResponse{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_patch/4

Updates a property.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Output only. Resource name of this property. Format: properties/{property_id} Example: "properties/1000"
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
    *   `:updateMask` (*type:* `String.t`) - Required. The list of fields to be updated. Field names must be in snake case (e.g., "field_to_update"). Omitted fields will not be updated. To replace the entire entity, use one path with the string "*" to match all fields.
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaProperty.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaProperty{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_run_access_report/4

Returns a customized report of data access records. The report provides records of each time a user reads Google Analytics reporting data. Access records are retained for up to 2 years. Data Access Reports can be requested for a property. Reports may be requested for any property, but dimensions that aren't related to quota can only be requested on Google Analytics 360 properties. This method is only available to Administrators. These data access records include GA UI Reporting, GA UI Explorations, GA Data API, and other products like Firebase & Admob that can retrieve data from Google Analytics through a linkage. These records don't include property configuration changes like adding a stream or changing a property's time zone. For configuration change history, see [searchChangeHistoryEvents](https://developers.google.com/analytics/devguides/config/admin/v1/rest/v1alpha/accounts/searchChangeHistoryEvents). To give your feedback on this API, complete the [Google Analytics Access Reports feedback](https://docs.google.com/forms/d/e/1FAIpQLSdmEBUrMzAEdiEKk5TV5dEHvDUZDRlgWYdQdAeSdtR4hVjEhw/viewform) form.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
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
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaRunAccessReportRequest.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaRunAccessReportResponse{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_update_data_retention_settings/4

Updates the singleton data retention settings for this property.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Output only. Resource name for this DataRetentionSetting resource. Format: properties/{property}/dataRetentionSettings
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
    *   `:updateMask` (*type:* `String.t`) - Required. The list of fields to be updated. Field names must be in snake case (e.g., "field_to_update"). Omitted fields will not be updated. To replace the entire entity, use one path with the string "*" to match all fields.
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaDataRetentionSettings.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaDataRetentionSettings{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_conversion_events_create/4

Deprecated: Use `CreateKeyEvent` instead. Creates a conversion event with the specified attributes.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `parent` (*type:* `String.t`) - Required. The resource name of the parent property where this conversion event will be created. Format: properties/123
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
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaConversionEvent.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaConversionEvent{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_conversion_events_delete/4

Deprecated: Use `DeleteKeyEvent` instead. Deletes a conversion event in a property.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Required. The resource name of the conversion event to delete. Format: properties/{property}/conversionEvents/{conversion_event} Example: "properties/123/conversionEvents/456"
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

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleProtobufEmpty{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_conversion_events_get/4

Deprecated: Use `GetKeyEvent` instead. Retrieve a single conversion event.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Required. The resource name of the conversion event to retrieve. Format: properties/{property}/conversionEvents/{conversion_event} Example: "properties/123/conversionEvents/456"
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

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaConversionEvent{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_conversion_events_list/4

Deprecated: Use `ListKeyEvents` instead. Returns a list of conversion events in the specified parent property. Returns an empty list if no conversion events are found.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `parent` (*type:* `String.t`) - Required. The resource name of the parent property. Example: 'properties/123'
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
    *   `:pageSize` (*type:* `integer()`) - The maximum number of resources to return. If unspecified, at most 50 resources will be returned. The maximum value is 200; (higher values will be coerced to the maximum)
    *   `:pageToken` (*type:* `String.t`) - A page token, received from a previous `ListConversionEvents` call. Provide this to retrieve the subsequent page. When paginating, all other parameters provided to `ListConversionEvents` must match the call that provided the page token.
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaListConversionEventsResponse{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_conversion_events_patch/4

Deprecated: Use `UpdateKeyEvent` instead. Updates a conversion event with the specified attributes.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Output only. Resource name of this conversion event. Format: properties/{property}/conversionEvents/{conversion_event}
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
    *   `:updateMask` (*type:* `String.t`) - Required. The list of fields to be updated. Field names must be in snake case (e.g., "field_to_update"). Omitted fields will not be updated. To replace the entire entity, use one path with the string "*" to match all fields.
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaConversionEvent.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaConversionEvent{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_custom_dimensions_archive/4

Archives a CustomDimension on a property.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Required. The name of the CustomDimension to archive. Example format: properties/1234/customDimensions/5678
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
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaArchiveCustomDimensionRequest.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleProtobufEmpty{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_custom_dimensions_create/4

Creates a CustomDimension.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `parent` (*type:* `String.t`) - Required. Example format: properties/1234
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
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaCustomDimension.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaCustomDimension{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_custom_dimensions_get/4

Lookup for a single CustomDimension.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Required. The name of the CustomDimension to get. Example format: properties/1234/customDimensions/5678
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

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaCustomDimension{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_custom_dimensions_list/4

Lists CustomDimensions on a property.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `parent` (*type:* `String.t`) - Required. Example format: properties/1234
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
    *   `:pageSize` (*type:* `integer()`) - The maximum number of resources to return. If unspecified, at most 50 resources will be returned. The maximum value is 200 (higher values will be coerced to the maximum).
    *   `:pageToken` (*type:* `String.t`) - A page token, received from a previous `ListCustomDimensions` call. Provide this to retrieve the subsequent page. When paginating, all other parameters provided to `ListCustomDimensions` must match the call that provided the page token.
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaListCustomDimensionsResponse{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_custom_dimensions_patch/4

Updates a CustomDimension on a property.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Output only. Resource name for this CustomDimension resource. Format: properties/{property}/customDimensions/{customDimension}
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
    *   `:updateMask` (*type:* `String.t`) - Required. The list of fields to be updated. Omitted fields will not be updated. To replace the entire entity, use one path with the string "*" to match all fields.
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaCustomDimension.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaCustomDimension{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_custom_metrics_archive/4

Archives a CustomMetric on a property.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Required. The name of the CustomMetric to archive. Example format: properties/1234/customMetrics/5678
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
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaArchiveCustomMetricRequest.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleProtobufEmpty{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_custom_metrics_create/4

Creates a CustomMetric.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `parent` (*type:* `String.t`) - Required. Example format: properties/1234
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
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaCustomMetric.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaCustomMetric{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_custom_metrics_get/4

Lookup for a single CustomMetric.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Required. The name of the CustomMetric to get. Example format: properties/1234/customMetrics/5678
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

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaCustomMetric{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_custom_metrics_list/4

Lists CustomMetrics on a property.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `parent` (*type:* `String.t`) - Required. Example format: properties/1234
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
    *   `:pageSize` (*type:* `integer()`) - The maximum number of resources to return. If unspecified, at most 50 resources will be returned. The maximum value is 200 (higher values will be coerced to the maximum).
    *   `:pageToken` (*type:* `String.t`) - A page token, received from a previous `ListCustomMetrics` call. Provide this to retrieve the subsequent page. When paginating, all other parameters provided to `ListCustomMetrics` must match the call that provided the page token.
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaListCustomMetricsResponse{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_custom_metrics_patch/4

Updates a CustomMetric on a property.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Output only. Resource name for this CustomMetric resource. Format: properties/{property}/customMetrics/{customMetric}
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
    *   `:updateMask` (*type:* `String.t`) - Required. The list of fields to be updated. Omitted fields will not be updated. To replace the entire entity, use one path with the string "*" to match all fields.
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaCustomMetric.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaCustomMetric{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_data_streams_create/4

Creates a DataStream.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `parent` (*type:* `String.t`) - Required. Example format: properties/1234
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
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaDataStream.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaDataStream{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_data_streams_delete/4

Deletes a DataStream on a property.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Required. The name of the DataStream to delete. Example format: properties/1234/dataStreams/5678
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

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleProtobufEmpty{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_data_streams_get/4

Lookup for a single DataStream.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Required. The name of the DataStream to get. Example format: properties/1234/dataStreams/5678
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

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaDataStream{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_data_streams_list/4

Lists DataStreams on a property.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `parent` (*type:* `String.t`) - Required. Example format: properties/1234
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
    *   `:pageSize` (*type:* `integer()`) - The maximum number of resources to return. If unspecified, at most 50 resources will be returned. The maximum value is 200 (higher values will be coerced to the maximum).
    *   `:pageToken` (*type:* `String.t`) - A page token, received from a previous `ListDataStreams` call. Provide this to retrieve the subsequent page. When paginating, all other parameters provided to `ListDataStreams` must match the call that provided the page token.
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaListDataStreamsResponse{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_data_streams_patch/4

Updates a DataStream on a property.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Output only. Resource name of this Data Stream. Format: properties/{property_id}/dataStreams/{stream_id} Example: "properties/1000/dataStreams/2000"
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
    *   `:updateMask` (*type:* `String.t`) - Required. The list of fields to be updated. Omitted fields will not be updated. To replace the entire entity, use one path with the string "*" to match all fields.
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaDataStream.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaDataStream{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_data_streams_measurement_protocol_secrets_create/4

Creates a measurement protocol secret.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `parent` (*type:* `String.t`) - Required. The parent resource where this secret will be created. Format: properties/{property}/dataStreams/{dataStream}
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
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaMeasurementProtocolSecret.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaMeasurementProtocolSecret{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_data_streams_measurement_protocol_secrets_delete/4

Deletes target MeasurementProtocolSecret.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Required. The name of the MeasurementProtocolSecret to delete. Format: properties/{property}/dataStreams/{dataStream}/measurementProtocolSecrets/{measurementProtocolSecret}
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

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleProtobufEmpty{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_data_streams_measurement_protocol_secrets_get/4

Lookup for a single MeasurementProtocolSecret.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Required. The name of the measurement protocol secret to lookup. Format: properties/{property}/dataStreams/{dataStream}/measurementProtocolSecrets/{measurementProtocolSecret}
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

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaMeasurementProtocolSecret{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_data_streams_measurement_protocol_secrets_list/4

Returns child MeasurementProtocolSecrets under the specified parent Property.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `parent` (*type:* `String.t`) - Required. The resource name of the parent stream. Format: properties/{property}/dataStreams/{dataStream}/measurementProtocolSecrets
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
    *   `:pageSize` (*type:* `integer()`) - The maximum number of resources to return. If unspecified, at most 10 resources will be returned. The maximum value is 10. Higher values will be coerced to the maximum.
    *   `:pageToken` (*type:* `String.t`) - A page token, received from a previous `ListMeasurementProtocolSecrets` call. Provide this to retrieve the subsequent page. When paginating, all other parameters provided to `ListMeasurementProtocolSecrets` must match the call that provided the page token.
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaListMeasurementProtocolSecretsResponse{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_data_streams_measurement_protocol_secrets_patch/4

Updates a measurement protocol secret.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Output only. Resource name of this secret. This secret may be a child of any type of stream. Format: properties/{property}/dataStreams/{dataStream}/measurementProtocolSecrets/{measurementProtocolSecret}
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
    *   `:updateMask` (*type:* `String.t`) - Required. The list of fields to be updated. Omitted fields will not be updated.
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaMeasurementProtocolSecret.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaMeasurementProtocolSecret{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_firebase_links_create/4

Creates a FirebaseLink. Properties can have at most one FirebaseLink.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `parent` (*type:* `String.t`) - Required. Format: properties/{property_id} Example: `properties/1234`
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
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaFirebaseLink.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaFirebaseLink{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_firebase_links_delete/4

Deletes a FirebaseLink on a property

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Required. Format: properties/{property_id}/firebaseLinks/{firebase_link_id} Example: `properties/1234/firebaseLinks/5678`
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

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleProtobufEmpty{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_firebase_links_list/4

Lists FirebaseLinks on a property. Properties can have at most one FirebaseLink.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `parent` (*type:* `String.t`) - Required. Format: properties/{property_id} Example: `properties/1234`
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
    *   `:pageToken` (*type:* `String.t`) - A page token, received from a previous `ListFirebaseLinks` call. Provide this to retrieve the subsequent page. When paginating, all other parameters provided to `ListFirebaseLinks` must match the call that provided the page token.
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaListFirebaseLinksResponse{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_google_ads_links_create/4

Creates a GoogleAdsLink.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `parent` (*type:* `String.t`) - Required. Example format: properties/1234
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
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaGoogleAdsLink.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaGoogleAdsLink{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_google_ads_links_delete/4

Deletes a GoogleAdsLink on a property

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Required. Example format: properties/1234/googleAdsLinks/5678
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

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleProtobufEmpty{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_google_ads_links_list/4

Lists GoogleAdsLinks on a property.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `parent` (*type:* `String.t`) - Required. Example format: properties/1234
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
    *   `:pageSize` (*type:* `integer()`) - The maximum number of resources to return. If unspecified, at most 50 resources will be returned. The maximum value is 200 (higher values will be coerced to the maximum).
    *   `:pageToken` (*type:* `String.t`) - A page token, received from a previous `ListGoogleAdsLinks` call. Provide this to retrieve the subsequent page. When paginating, all other parameters provided to `ListGoogleAdsLinks` must match the call that provided the page token.
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaListGoogleAdsLinksResponse{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_google_ads_links_patch/4

Updates a GoogleAdsLink on a property

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Output only. Format: properties/{propertyId}/googleAdsLinks/{googleAdsLinkId} Note: googleAdsLinkId is not the Google Ads customer ID.
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
    *   `:updateMask` (*type:* `String.t`) - Required. The list of fields to be updated. Field names must be in snake case (e.g., "field_to_update"). Omitted fields will not be updated. To replace the entire entity, use one path with the string "*" to match all fields.
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaGoogleAdsLink.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaGoogleAdsLink{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_key_events_create/4

Creates a Key Event.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `parent` (*type:* `String.t`) - Required. The resource name of the parent property where this Key Event will be created. Format: properties/123
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
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaKeyEvent.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaKeyEvent{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_key_events_delete/4

Deletes a Key Event.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Required. The resource name of the Key Event to delete. Format: properties/{property}/keyEvents/{key_event} Example: "properties/123/keyEvents/456"
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

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleProtobufEmpty{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_key_events_get/4

Retrieve a single Key Event.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Required. The resource name of the Key Event to retrieve. Format: properties/{property}/keyEvents/{key_event} Example: "properties/123/keyEvents/456"
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

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaKeyEvent{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_key_events_list/4

Returns a list of Key Events in the specified parent property. Returns an empty list if no Key Events are found.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `parent` (*type:* `String.t`) - Required. The resource name of the parent property. Example: 'properties/123'
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
    *   `:pageSize` (*type:* `integer()`) - The maximum number of resources to return. If unspecified, at most 50 resources will be returned. The maximum value is 200; (higher values will be coerced to the maximum)
    *   `:pageToken` (*type:* `String.t`) - A page token, received from a previous `ListKeyEvents` call. Provide this to retrieve the subsequent page. When paginating, all other parameters provided to `ListKeyEvents` must match the call that provided the page token.
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaListKeyEventsResponse{}}` on success
*   `{:error, info}` on failure

## analyticsadmin_properties_key_events_patch/4

Updates a Key Event.

## Parameters

*   `connection` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Connection.t`) - Connection to server
*   `name` (*type:* `String.t`) - Output only. Resource name of this key event. Format: properties/{property}/keyEvents/{key_event}
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
    *   `:updateMask` (*type:* `String.t`) - Required. The list of fields to be updated. Field names must be in snake case (e.g., "field_to_update"). Omitted fields will not be updated. To replace the entire entity, use one path with the string "*" to match all fields.
    *   `:body` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaKeyEvent.t`) - 
*   `opts` (*type:* `keyword()`) - Call options

## Returns

*   `{:ok, %GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaKeyEvent{}}` on success
*   `{:error, info}` on failure