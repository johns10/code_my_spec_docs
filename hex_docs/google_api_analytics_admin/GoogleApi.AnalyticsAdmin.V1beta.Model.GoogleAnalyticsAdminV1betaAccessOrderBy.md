# GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaAccessOrderBy

Order bys define how rows will be sorted in the response. For example, ordering rows by descending access count is one ordering, and ordering rows by the country string is a different ordering.

## Attributes

*   `desc` (*type:* `boolean()`, *default:* `nil`) - If true, sorts by descending order. If false or unspecified, sorts in ascending order.
*   `dimension` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaAccessOrderByDimensionOrderBy.t`, *default:* `nil`) - Sorts results by a dimension's values.
*   `metric` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaAccessOrderByMetricOrderBy.t`, *default:* `nil`) - Sorts results by a metric's values.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.