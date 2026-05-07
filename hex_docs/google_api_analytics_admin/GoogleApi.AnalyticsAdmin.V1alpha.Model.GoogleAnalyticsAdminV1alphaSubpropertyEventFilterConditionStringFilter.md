# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaSubpropertyEventFilterConditionStringFilter

A filter for a string-type dimension that matches a particular pattern.

## Attributes

*   `caseSensitive` (*type:* `boolean()`, *default:* `nil`) - Optional. If true, the string value is case sensitive. If false, the match is case-insensitive.
*   `matchType` (*type:* `String.t`, *default:* `nil`) - Required. The match type for the string filter.
*   `value` (*type:* `String.t`, *default:* `nil`) - Required. The string value used for the matching.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.