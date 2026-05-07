# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaCalculatedMetric

A definition for a calculated metric.

## Attributes

*   `calculatedMetricId` (*type:* `String.t`, *default:* `nil`) - Output only. The ID to use for the calculated metric. In the UI, this is referred to as the "API name." The calculated_metric_id is used when referencing this calculated metric from external APIs. For example, "calcMetric:{calculated_metric_id}".
*   `description` (*type:* `String.t`, *default:* `nil`) - Optional. Description for this calculated metric. Max length of 4096 characters.
*   `displayName` (*type:* `String.t`, *default:* `nil`) - Required. Display name for this calculated metric as shown in the Google Analytics UI. Max length 82 characters.
*   `formula` (*type:* `String.t`, *default:* `nil`) - Required. The calculated metric's definition. Maximum number of unique referenced custom metrics is 5. Formulas supports the following operations: + (addition), - (subtraction), - (negative), * (multiplication), / (division), () (parenthesis). Any valid real numbers are acceptable that fit in a Long (64bit integer) or a Double (64 bit floating point number). Example formula: "( customEvent:parameter_name + cartPurchaseQuantity ) / 2.0"
*   `invalidMetricReference` (*type:* `boolean()`, *default:* `nil`) - Output only. If true, this calculated metric has a invalid metric reference. Anything using a calculated metric with invalid_metric_reference set to true may fail, produce warnings, or produce unexpected results.
*   `metricUnit` (*type:* `String.t`, *default:* `nil`) - Required. The type for the calculated metric's value.
*   `name` (*type:* `String.t`, *default:* `nil`) - Output only. Resource name for this CalculatedMetric. Format: 'properties/{property_id}/calculatedMetrics/{calculated_metric_id}'
*   `restrictedMetricType` (*type:* `list(String.t)`, *default:* `nil`) - Output only. Types of restricted data that this metric contains.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.