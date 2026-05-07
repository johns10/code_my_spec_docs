# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAudienceSimpleFilter

Defines a simple filter that a user must satisfy to be a member of the Audience.

## Attributes

*   `filterExpression` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAudienceFilterExpression.t`, *default:* `nil`) - Required. Immutable. A logical expression of Audience dimension, metric, or event filters.
*   `scope` (*type:* `String.t`, *default:* `nil`) - Required. Immutable. Specifies the scope for this filter.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.