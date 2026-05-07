# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaListSubpropertyEventFiltersResponse

Response message for ListSubpropertyEventFilter RPC.

## Attributes

*   `nextPageToken` (*type:* `String.t`, *default:* `nil`) - A token, which can be sent as `page_token` to retrieve the next page. If this field is omitted, there are no subsequent pages.
*   `subpropertyEventFilters` (*type:* `list(GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaSubpropertyEventFilter.t)`, *default:* `nil`) - List of subproperty event filters.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.