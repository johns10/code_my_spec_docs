# GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaSearchChangeHistoryEventsRequest

Request message for SearchChangeHistoryEvents RPC.

## Attributes

*   `action` (*type:* `list(String.t)`, *default:* `nil`) - Optional. If set, only return changes that match one or more of these types of actions.
*   `actorEmail` (*type:* `list(String.t)`, *default:* `nil`) - Optional. If set, only return changes if they are made by a user in this list.
*   `earliestChangeTime` (*type:* `DateTime.t`, *default:* `nil`) - Optional. If set, only return changes made after this time (inclusive).
*   `latestChangeTime` (*type:* `DateTime.t`, *default:* `nil`) - Optional. If set, only return changes made before this time (inclusive).
*   `pageSize` (*type:* `integer()`, *default:* `nil`) - Optional. The maximum number of ChangeHistoryEvent items to return. If unspecified, at most 50 items will be returned. The maximum value is 200 (higher values will be coerced to the maximum). Note that the service may return a page with fewer items than this value specifies (potentially even zero), and that there still may be additional pages. If you want a particular number of items, you'll need to continue requesting additional pages using `page_token` until you get the needed number.
*   `pageToken` (*type:* `String.t`, *default:* `nil`) - Optional. A page token, received from a previous `SearchChangeHistoryEvents` call. Provide this to retrieve the subsequent page. When paginating, all other parameters provided to `SearchChangeHistoryEvents` must match the call that provided the page token.
*   `property` (*type:* `String.t`, *default:* `nil`) - Optional. Resource name for a child property. If set, only return changes made to this property or its child resources. Format: properties/{propertyId} Example: `properties/100`
*   `resourceType` (*type:* `list(String.t)`, *default:* `nil`) - Optional. If set, only return changes if they are for a resource that matches at least one of these types.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.