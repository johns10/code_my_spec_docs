# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaProperty

A resource message representing a Google Analytics property.

## Attributes

*   `account` (*type:* `String.t`, *default:* `nil`) - Immutable. The resource name of the parent account Format: accounts/{account_id} Example: "accounts/123"
*   `createTime` (*type:* `DateTime.t`, *default:* `nil`) - Output only. Time when the entity was originally created.
*   `currencyCode` (*type:* `String.t`, *default:* `nil`) - The currency type used in reports involving monetary values. Format: https://en.wikipedia.org/wiki/ISO_4217 Examples: "USD", "EUR", "JPY"
*   `deleteTime` (*type:* `DateTime.t`, *default:* `nil`) - Output only. If set, the time at which this property was trashed. If not set, then this property is not currently in the trash can.
*   `displayName` (*type:* `String.t`, *default:* `nil`) - Required. Human-readable display name for this property. The max allowed display name length is 100 UTF-16 code units.
*   `expireTime` (*type:* `DateTime.t`, *default:* `nil`) - Output only. If set, the time at which this trashed property will be permanently deleted. If not set, then this property is not currently in the trash can and is not slated to be deleted.
*   `industryCategory` (*type:* `String.t`, *default:* `nil`) - Industry associated with this property Example: AUTOMOTIVE, FOOD_AND_DRINK
*   `name` (*type:* `String.t`, *default:* `nil`) - Output only. Resource name of this property. Format: properties/{property_id} Example: "properties/1000"
*   `parent` (*type:* `String.t`, *default:* `nil`) - Immutable. Resource name of this property's logical parent. Note: The Property-Moving UI can be used to change the parent. Format: accounts/{account}, properties/{property} Example: "accounts/100", "properties/101"
*   `propertyType` (*type:* `String.t`, *default:* `nil`) - Immutable. The property type for this Property resource. When creating a property, if the type is "PROPERTY_TYPE_UNSPECIFIED", then "ORDINARY_PROPERTY" will be implied.
*   `serviceLevel` (*type:* `String.t`, *default:* `nil`) - Output only. The Google Analytics service level that applies to this property.
*   `timeZone` (*type:* `String.t`, *default:* `nil`) - Required. Reporting Time Zone, used as the day boundary for reports, regardless of where the data originates. If the time zone honors DST, Analytics will automatically adjust for the changes. NOTE: Changing the time zone only affects data going forward, and is not applied retroactively. Format: https://www.iana.org/time-zones Example: "America/Los_Angeles"
*   `updateTime` (*type:* `DateTime.t`, *default:* `nil`) - Output only. Time when entity payload fields were last updated.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.