# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaExpandedDataSet

A resource message representing an `ExpandedDataSet`.

## Attributes

*   `dataCollectionStartTime` (*type:* `DateTime.t`, *default:* `nil`) - Output only. Time when expanded data set began (or will begin) collecing data.
*   `description` (*type:* `String.t`, *default:* `nil`) - Optional. The description of the ExpandedDataSet. Max 50 chars.
*   `dimensionFilterExpression` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaExpandedDataSetFilterExpression.t`, *default:* `nil`) - Immutable. A logical expression of ExpandedDataSet filters applied to dimension included in the ExpandedDataSet. This filter is used to reduce the number of rows and thus the chance of encountering `other` row.
*   `dimensionNames` (*type:* `list(String.t)`, *default:* `nil`) - Immutable. The list of dimensions included in the ExpandedDataSet. See the [API Dimensions](https://developers.google.com/analytics/devguides/reporting/data/v1/api-schema#dimensions) for the list of dimension names.
*   `displayName` (*type:* `String.t`, *default:* `nil`) - Required. The display name of the ExpandedDataSet. Max 200 chars.
*   `metricNames` (*type:* `list(String.t)`, *default:* `nil`) - Immutable. The list of metrics included in the ExpandedDataSet. See the [API Metrics](https://developers.google.com/analytics/devguides/reporting/data/v1/api-schema#metrics) for the list of dimension names.
*   `name` (*type:* `String.t`, *default:* `nil`) - Output only. The resource name for this ExpandedDataSet resource. Format: properties/{property_id}/expandedDataSets/{expanded_data_set}

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.