# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaListMeasurementProtocolSecretsResponse

Response message for ListMeasurementProtocolSecret RPC

## Attributes

*   `measurementProtocolSecrets` (*type:* `list(GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaMeasurementProtocolSecret.t)`, *default:* `nil`) - A list of secrets for the parent stream specified in the request.
*   `nextPageToken` (*type:* `String.t`, *default:* `nil`) - A token, which can be sent as `page_token` to retrieve the next page. If this field is omitted, there are no subsequent pages.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.