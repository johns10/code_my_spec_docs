# GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaAccessFilter

An expression to filter dimension or metric values.

## Attributes

*   `betweenFilter` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaAccessBetweenFilter.t`, *default:* `nil`) - A filter for two values.
*   `fieldName` (*type:* `String.t`, *default:* `nil`) - The dimension name or metric name.
*   `inListFilter` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaAccessInListFilter.t`, *default:* `nil`) - A filter for in list values.
*   `numericFilter` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaAccessNumericFilter.t`, *default:* `nil`) - A filter for numeric or date values.
*   `stringFilter` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaAccessStringFilter.t`, *default:* `nil`) - Strings related filter.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.