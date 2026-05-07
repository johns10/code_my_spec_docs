# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAudienceFilterExpression

A logical expression of Audience dimension, metric, or event filters.

## Attributes

*   `andGroup` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAudienceFilterExpressionList.t`, *default:* `nil`) - A list of expressions to be AND’ed together. It can only contain AudienceFilterExpressions with or_group. This must be set for the top level AudienceFilterExpression.
*   `dimensionOrMetricFilter` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAudienceDimensionOrMetricFilter.t`, *default:* `nil`) - A filter on a single dimension or metric. This cannot be set on the top level AudienceFilterExpression.
*   `eventFilter` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAudienceEventFilter.t`, *default:* `nil`) - Creates a filter that matches a specific event. This cannot be set on the top level AudienceFilterExpression.
*   `notExpression` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAudienceFilterExpression.t`, *default:* `nil`) - A filter expression to be NOT'ed (For example, inverted, complemented). It can only include a dimension_or_metric_filter. This cannot be set on the top level AudienceFilterExpression.
*   `orGroup` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAudienceFilterExpressionList.t`, *default:* `nil`) - A list of expressions to OR’ed together. It cannot contain AudienceFilterExpressions with and_group or or_group.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.