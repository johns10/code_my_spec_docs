# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaListRollupPropertySourceLinksResponse

Response message for ListRollupPropertySourceLinks RPC.

## Attributes

*   `nextPageToken` (*type:* `String.t`, *default:* `nil`) - A token, which can be sent as `page_token` to retrieve the next page. If this field is omitted, there are no subsequent pages.
*   `rollupPropertySourceLinks` (*type:* `list(GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaRollupPropertySourceLink.t)`, *default:* `nil`) - List of RollupPropertySourceLinks.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.