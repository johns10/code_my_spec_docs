# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaListDataStreamsResponse

Response message for ListDataStreams RPC.

## Attributes

*   `dataStreams` (*type:* `list(GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaDataStream.t)`, *default:* `nil`) - List of DataStreams.
*   `nextPageToken` (*type:* `String.t`, *default:* `nil`) - A token, which can be sent as `page_token` to retrieve the next page. If this field is omitted, there are no subsequent pages.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.