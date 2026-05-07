# GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaCustomMetric

A definition for a custom metric.

## Attributes

*   `description` (*type:* `String.t`, *default:* `nil`) - Optional. Description for this custom dimension. Max length of 150 characters.
*   `displayName` (*type:* `String.t`, *default:* `nil`) - Required. Display name for this custom metric as shown in the Analytics UI. Max length of 82 characters, alphanumeric plus space and underscore starting with a letter. Legacy system-generated display names may contain square brackets, but updates to this field will never permit square brackets.
*   `measurementUnit` (*type:* `String.t`, *default:* `nil`) - Required. The type for the custom metric's value.
*   `name` (*type:* `String.t`, *default:* `nil`) - Output only. Resource name for this CustomMetric resource. Format: properties/{property}/customMetrics/{customMetric}
*   `parameterName` (*type:* `String.t`, *default:* `nil`) - Required. Immutable. Tagging name for this custom metric. If this is an event-scoped metric, then this is the event parameter name. May only contain alphanumeric and underscore charactes, starting with a letter. Max length of 40 characters for event-scoped metrics.
*   `restrictedMetricType` (*type:* `list(String.t)`, *default:* `nil`) - Optional. Types of restricted data that this metric may contain. Required for metrics with CURRENCY measurement unit. Must be empty for metrics with a non-CURRENCY measurement unit.
*   `scope` (*type:* `String.t`, *default:* `nil`) - Required. Immutable. The scope of this custom metric.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.