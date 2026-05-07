# GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaListAccountSummariesResponse

Response message for ListAccountSummaries RPC.

## Attributes

*   `accountSummaries` (*type:* `list(GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaAccountSummary.t)`, *default:* `nil`) - Account summaries of all accounts the caller has access to.
*   `nextPageToken` (*type:* `String.t`, *default:* `nil`) - A token, which can be sent as `page_token` to retrieve the next page. If this field is omitted, there are no subsequent pages.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.