# GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaListCustomMetricsResponse

Response message for ListCustomMetrics RPC.

## Attributes

*   `customMetrics` (*type:* `list(GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaCustomMetric.t)`, *default:* `nil`) - List of CustomMetrics.
*   `nextPageToken` (*type:* `String.t`, *default:* `nil`) - A token, which can be sent as `page_token` to retrieve the next page. If this field is omitted, there are no subsequent pages.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.