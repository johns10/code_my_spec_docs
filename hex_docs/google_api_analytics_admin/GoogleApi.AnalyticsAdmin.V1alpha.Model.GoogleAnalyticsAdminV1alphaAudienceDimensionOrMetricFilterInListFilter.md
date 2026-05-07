# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAudienceDimensionOrMetricFilterInListFilter

A filter for a string dimension that matches a particular list of options.

## Attributes

*   `caseSensitive` (*type:* `boolean()`, *default:* `nil`) - Optional. If true, the match is case-sensitive. If false, the match is case-insensitive.
*   `values` (*type:* `list(String.t)`, *default:* `nil`) - Required. The list of possible string values to match against. Must be non-empty.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.