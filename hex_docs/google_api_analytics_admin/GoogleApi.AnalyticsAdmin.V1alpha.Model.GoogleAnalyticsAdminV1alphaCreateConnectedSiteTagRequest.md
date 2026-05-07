# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaCreateConnectedSiteTagRequest

Request message for CreateConnectedSiteTag RPC.

## Attributes

*   `connectedSiteTag` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaConnectedSiteTag.t`, *default:* `nil`) - Required. The tag to add to the Universal Analytics property
*   `property` (*type:* `String.t`, *default:* `nil`) - The Universal Analytics property to create connected site tags for. This API does not support GA4 properties. Format: properties/{universalAnalyticsPropertyId} Example: properties/1234

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.