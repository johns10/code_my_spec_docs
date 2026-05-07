# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaListAccountSummariesResponse

Response message for ListAccountSummaries RPC.

## Attributes

*   `accountSummaries` (*type:* `list(GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAccountSummary.t)`, *default:* `nil`) - Account summaries of all accounts the caller has access to.
*   `nextPageToken` (*type:* `String.t`, *default:* `nil`) - A token, which can be sent as `page_token` to retrieve the next page. If this field is omitted, there are no subsequent pages.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.