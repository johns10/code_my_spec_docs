# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaExpandedDataSetFilter

A specific filter for a single dimension

## Attributes

*   `fieldName` (*type:* `String.t`, *default:* `nil`) - Required. The dimension name to filter.
*   `inListFilter` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaExpandedDataSetFilterInListFilter.t`, *default:* `nil`) - A filter for a string dimension that matches a particular list of options.
*   `stringFilter` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaExpandedDataSetFilterStringFilter.t`, *default:* `nil`) - A filter for a string-type dimension that matches a particular pattern.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.