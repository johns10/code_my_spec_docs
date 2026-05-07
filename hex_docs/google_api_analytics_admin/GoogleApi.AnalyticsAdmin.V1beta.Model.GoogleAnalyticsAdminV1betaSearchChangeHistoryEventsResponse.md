# GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaSearchChangeHistoryEventsResponse

Response message for SearchAccounts RPC.

## Attributes

*   `changeHistoryEvents` (*type:* `list(GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaChangeHistoryEvent.t)`, *default:* `nil`) - Results that were accessible to the caller.
*   `nextPageToken` (*type:* `String.t`, *default:* `nil`) - A token, which can be sent as `page_token` to retrieve the next page. If this field is omitted, there are no subsequent pages.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.