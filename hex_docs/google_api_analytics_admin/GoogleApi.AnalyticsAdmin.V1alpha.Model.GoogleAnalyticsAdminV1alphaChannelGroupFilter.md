# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaChannelGroupFilter

A specific filter for a single dimension.

## Attributes

*   `fieldName` (*type:* `String.t`, *default:* `nil`) - Required. Immutable. The dimension name to filter.
*   `inListFilter` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaChannelGroupFilterInListFilter.t`, *default:* `nil`) - A filter for a string dimension that matches a particular list of options.
*   `stringFilter` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaChannelGroupFilterStringFilter.t`, *default:* `nil`) - A filter for a string-type dimension that matches a particular pattern.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.