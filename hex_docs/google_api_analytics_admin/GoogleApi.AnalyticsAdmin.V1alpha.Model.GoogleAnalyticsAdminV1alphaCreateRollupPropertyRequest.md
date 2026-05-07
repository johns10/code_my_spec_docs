# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaCreateRollupPropertyRequest

Request message for CreateRollupProperty RPC.

## Attributes

*   `rollupProperty` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaProperty.t`, *default:* `nil`) - Required. The roll-up property to create.
*   `sourceProperties` (*type:* `list(String.t)`, *default:* `nil`) - Optional. The resource names of properties that will be sources to the created roll-up property.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.