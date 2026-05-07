# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaListConversionEventsResponse

Response message for ListConversionEvents RPC.

## Attributes

*   `conversionEvents` (*type:* `list(GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaConversionEvent.t)`, *default:* `nil`) - The requested conversion events
*   `nextPageToken` (*type:* `String.t`, *default:* `nil`) - A token, which can be sent as `page_token` to retrieve the next page. If this field is omitted, there are no subsequent pages.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.