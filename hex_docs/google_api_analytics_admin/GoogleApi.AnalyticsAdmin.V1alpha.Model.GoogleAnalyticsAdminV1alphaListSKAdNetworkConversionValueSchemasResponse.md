# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaListSKAdNetworkConversionValueSchemasResponse

Response message for ListSKAdNetworkConversionValueSchemas RPC

## Attributes

*   `nextPageToken` (*type:* `String.t`, *default:* `nil`) - A token, which can be sent as `page_token` to retrieve the next page. If this field is omitted, there are no subsequent pages. Currently, Google Analytics supports only one SKAdNetworkConversionValueSchema per dataStream, so this will never be populated.
*   `skadnetworkConversionValueSchemas` (*type:* `list(GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaSKAdNetworkConversionValueSchema.t)`, *default:* `nil`) - List of SKAdNetworkConversionValueSchemas. This will have at most one value.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.