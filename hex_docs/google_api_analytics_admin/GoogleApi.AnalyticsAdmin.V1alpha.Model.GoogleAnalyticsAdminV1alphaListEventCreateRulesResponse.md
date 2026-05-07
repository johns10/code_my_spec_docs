# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaListEventCreateRulesResponse

Response message for ListEventCreateRules RPC.

## Attributes

*   `eventCreateRules` (*type:* `list(GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaEventCreateRule.t)`, *default:* `nil`) - List of EventCreateRules. These will be ordered stably, but in an arbitrary order.
*   `nextPageToken` (*type:* `String.t`, *default:* `nil`) - A token, which can be sent as `page_token` to retrieve the next page. If this field is omitted, there are no subsequent pages.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.