# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaConversionValues

Conversion value settings for a postback window for SKAdNetwork conversion value schema.

## Attributes

*   `coarseValue` (*type:* `String.t`, *default:* `nil`) - Required. A coarse grained conversion value. This value is not guaranteed to be unique.
*   `displayName` (*type:* `String.t`, *default:* `nil`) - Display name of the SKAdNetwork conversion value. The max allowed display name length is 50 UTF-16 code units.
*   `eventMappings` (*type:* `list(GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaEventMapping.t)`, *default:* `nil`) - Event conditions that must be met for this Conversion Value to be achieved. The conditions in this list are ANDed together. It must have minimum of 1 entry and maximum of 3 entries, if the postback window is enabled.
*   `fineValue` (*type:* `integer()`, *default:* `nil`) - The fine-grained conversion value. This is applicable only to the first postback window. Its valid values are [0,63], both inclusive. It must be set for postback window 1, and must not be set for postback window 2 & 3. This value is not guaranteed to be unique. If the configuration for the first postback window is re-used for second or third postback windows this field has no effect.
*   `lockEnabled` (*type:* `boolean()`, *default:* `nil`) - If true, the SDK should lock to this conversion value for the current postback window.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.