# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAccessMetricHeader

Describes a metric column in the report. Visible metrics requested in a report produce column entries within rows and MetricHeaders. However, metrics used exclusively within filters or expressions do not produce columns in a report; correspondingly, those metrics do not produce headers.

## Attributes

*   `metricName` (*type:* `String.t`, *default:* `nil`) - The metric's name; for example 'accessCount'.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.