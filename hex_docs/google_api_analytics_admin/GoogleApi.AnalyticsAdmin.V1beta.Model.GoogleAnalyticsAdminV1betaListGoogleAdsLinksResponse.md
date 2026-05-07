# GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaListGoogleAdsLinksResponse

Response message for ListGoogleAdsLinks RPC.

## Attributes

*   `googleAdsLinks` (*type:* `list(GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaGoogleAdsLink.t)`, *default:* `nil`) - List of GoogleAdsLinks.
*   `nextPageToken` (*type:* `String.t`, *default:* `nil`) - A token, which can be sent as `page_token` to retrieve the next page. If this field is omitted, there are no subsequent pages.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.