# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAccessFilter

An expression to filter dimension or metric values.

## Attributes

*   `betweenFilter` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAccessBetweenFilter.t`, *default:* `nil`) - A filter for two values.
*   `fieldName` (*type:* `String.t`, *default:* `nil`) - The dimension name or metric name.
*   `inListFilter` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAccessInListFilter.t`, *default:* `nil`) - A filter for in list values.
*   `numericFilter` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAccessNumericFilter.t`, *default:* `nil`) - A filter for numeric or date values.
*   `stringFilter` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAccessStringFilter.t`, *default:* `nil`) - Strings related filter.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.