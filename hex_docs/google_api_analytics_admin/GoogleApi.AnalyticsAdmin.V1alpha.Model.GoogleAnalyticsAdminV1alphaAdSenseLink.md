# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAdSenseLink

A link between a Google Analytics property and an AdSense for Content ad client.

## Attributes

*   `adClientCode` (*type:* `String.t`, *default:* `nil`) - Immutable. The AdSense ad client code that the Google Analytics property is linked to. Example format: "ca-pub-1234567890"
*   `name` (*type:* `String.t`, *default:* `nil`) - Output only. The resource name for this AdSense Link resource. Format: properties/{propertyId}/adSenseLinks/{linkId} Example: properties/1234/adSenseLinks/6789

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.