# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaExpandedDataSetFilterExpression

A logical expression of EnhancedDataSet dimension filters.

## Attributes

*   `andGroup` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaExpandedDataSetFilterExpressionList.t`, *default:* `nil`) - A list of expressions to be AND’ed together. It must contain a ExpandedDataSetFilterExpression with either not_expression or dimension_filter. This must be set for the top level ExpandedDataSetFilterExpression.
*   `filter` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaExpandedDataSetFilter.t`, *default:* `nil`) - A filter on a single dimension. This cannot be set on the top level ExpandedDataSetFilterExpression.
*   `notExpression` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaExpandedDataSetFilterExpression.t`, *default:* `nil`) - A filter expression to be NOT'ed (that is, inverted, complemented). It must include a dimension_filter. This cannot be set on the top level ExpandedDataSetFilterExpression.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.