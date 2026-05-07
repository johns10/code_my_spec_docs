# GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaAccessFilterExpression

Expresses dimension or metric filters. The fields in the same expression need to be either all dimensions or all metrics.

## Attributes

*   `accessFilter` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaAccessFilter.t`, *default:* `nil`) - A primitive filter. In the same FilterExpression, all of the filter's field names need to be either all dimensions or all metrics.
*   `andGroup` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaAccessFilterExpressionList.t`, *default:* `nil`) - Each of the FilterExpressions in the and_group has an AND relationship.
*   `notExpression` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaAccessFilterExpression.t`, *default:* `nil`) - The FilterExpression is NOT of not_expression.
*   `orGroup` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaAccessFilterExpressionList.t`, *default:* `nil`) - Each of the FilterExpressions in the or_group has an OR relationship.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.