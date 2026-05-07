# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaRollupPropertySourceLink

A link that references a source property under the parent rollup property.

## Attributes

*   `name` (*type:* `String.t`, *default:* `nil`) - Output only. Resource name of this RollupPropertySourceLink. Format: 'properties/{property_id}/rollupPropertySourceLinks/{rollup_property_source_link}' Format: 'properties/123/rollupPropertySourceLinks/456'
*   `sourceProperty` (*type:* `String.t`, *default:* `nil`) - Immutable. Resource name of the source property. Format: properties/{property_id} Example: "properties/789"

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.