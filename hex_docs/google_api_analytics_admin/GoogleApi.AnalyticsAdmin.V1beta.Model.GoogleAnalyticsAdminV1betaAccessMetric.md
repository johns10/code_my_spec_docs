# GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaAccessMetric

The quantitative measurements of a report. For example, the metric `accessCount` is the total number of data access records.

## Attributes

*   `metricName` (*type:* `String.t`, *default:* `nil`) - The API name of the metric. See [Data Access Schema](https://developers.google.com/analytics/devguides/config/admin/v1/access-api-schema) for the list of metrics supported in this API. Metrics are referenced by name in `metricFilter` & `orderBys`.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.