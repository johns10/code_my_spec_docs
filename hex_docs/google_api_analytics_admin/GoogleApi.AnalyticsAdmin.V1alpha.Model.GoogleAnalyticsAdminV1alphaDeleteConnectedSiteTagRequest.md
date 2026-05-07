# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaDeleteConnectedSiteTagRequest

Request message for DeleteConnectedSiteTag RPC.

## Attributes

*   `property` (*type:* `String.t`, *default:* `nil`) - The Universal Analytics property to delete connected site tags for. This API does not support GA4 properties. Format: properties/{universalAnalyticsPropertyId} Example: properties/1234
*   `tagId` (*type:* `String.t`, *default:* `nil`) - Tag ID to forward events to. Also known as the Measurement ID, or the "G-ID" (For example: G-12345).

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.