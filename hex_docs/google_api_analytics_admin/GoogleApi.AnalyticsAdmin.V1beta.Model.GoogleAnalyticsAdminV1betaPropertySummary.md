# GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaPropertySummary

A virtual resource representing metadata for a Google Analytics property.

## Attributes

*   `displayName` (*type:* `String.t`, *default:* `nil`) - Display name for the property referred to in this property summary.
*   `parent` (*type:* `String.t`, *default:* `nil`) - Resource name of this property's logical parent. Note: The Property-Moving UI can be used to change the parent. Format: accounts/{account}, properties/{property} Example: "accounts/100", "properties/200"
*   `property` (*type:* `String.t`, *default:* `nil`) - Resource name of property referred to by this property summary Format: properties/{property_id} Example: "properties/1000"
*   `propertyType` (*type:* `String.t`, *default:* `nil`) - The property's property type.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.