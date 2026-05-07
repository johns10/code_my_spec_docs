# GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaListPropertiesResponse

Response message for ListProperties RPC.

## Attributes

*   `nextPageToken` (*type:* `String.t`, *default:* `nil`) - A token, which can be sent as `page_token` to retrieve the next page. If this field is omitted, there are no subsequent pages.
*   `properties` (*type:* `list(GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaProperty.t)`, *default:* `nil`) - Results that matched the filter criteria and were accessible to the caller.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.