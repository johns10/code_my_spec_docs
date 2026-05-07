# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaSubpropertyEventFilterExpression

A logical expression of Subproperty event filters.

## Attributes

*   `filterCondition` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaSubpropertyEventFilterCondition.t`, *default:* `nil`) - Creates a filter that matches a specific event. This cannot be set on the top level SubpropertyEventFilterExpression.
*   `notExpression` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaSubpropertyEventFilterExpression.t`, *default:* `nil`) - A filter expression to be NOT'ed (inverted, complemented). It can only include a filter. This cannot be set on the top level SubpropertyEventFilterExpression.
*   `orGroup` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaSubpropertyEventFilterExpressionList.t`, *default:* `nil`) - A list of expressions to OR’ed together. Must only contain not_expression or filter_condition expressions.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.