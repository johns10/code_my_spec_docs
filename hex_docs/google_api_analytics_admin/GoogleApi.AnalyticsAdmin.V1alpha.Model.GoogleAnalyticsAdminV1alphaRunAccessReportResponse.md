# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaRunAccessReportResponse

The customized Data Access Record Report response.

## Attributes

*   `dimensionHeaders` (*type:* `list(GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAccessDimensionHeader.t)`, *default:* `nil`) - The header for a column in the report that corresponds to a specific dimension. The number of DimensionHeaders and ordering of DimensionHeaders matches the dimensions present in rows.
*   `metricHeaders` (*type:* `list(GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAccessMetricHeader.t)`, *default:* `nil`) - The header for a column in the report that corresponds to a specific metric. The number of MetricHeaders and ordering of MetricHeaders matches the metrics present in rows.
*   `quota` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAccessQuota.t`, *default:* `nil`) - The quota state for this Analytics property including this request. This field doesn't work with account-level requests.
*   `rowCount` (*type:* `integer()`, *default:* `nil`) - The total number of rows in the query result. `rowCount` is independent of the number of rows returned in the response, the `limit` request parameter, and the `offset` request parameter. For example if a query returns 175 rows and includes `limit` of 50 in the API request, the response will contain `rowCount` of 175 but only 50 rows. To learn more about this pagination parameter, see [Pagination](https://developers.google.com/analytics/devguides/reporting/data/v1/basics#pagination).
*   `rows` (*type:* `list(GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAccessRow.t)`, *default:* `nil`) - Rows of dimension value combinations and metric values in the report.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.