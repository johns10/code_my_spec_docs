# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaChannelGroupFilterExpression

A logical expression of Channel Group dimension filters.

## Attributes

*   `andGroup` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaChannelGroupFilterExpressionList.t`, *default:* `nil`) - A list of expressions to be AND’ed together. It can only contain ChannelGroupFilterExpressions with or_group. This must be set for the top level ChannelGroupFilterExpression.
*   `filter` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaChannelGroupFilter.t`, *default:* `nil`) - A filter on a single dimension. This cannot be set on the top level ChannelGroupFilterExpression.
*   `notExpression` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaChannelGroupFilterExpression.t`, *default:* `nil`) - A filter expression to be NOT'ed (that is inverted, complemented). It can only include a dimension_or_metric_filter. This cannot be set on the top level ChannelGroupFilterExpression.
*   `orGroup` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaChannelGroupFilterExpressionList.t`, *default:* `nil`) - A list of expressions to OR’ed together. It cannot contain ChannelGroupFilterExpressions with and_group or or_group.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.