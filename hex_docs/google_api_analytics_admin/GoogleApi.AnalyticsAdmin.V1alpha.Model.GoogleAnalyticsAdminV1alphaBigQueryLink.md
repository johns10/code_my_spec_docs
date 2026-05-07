# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaBigQueryLink

A link between a Google Analytics property and BigQuery project.

## Attributes

*   `createTime` (*type:* `DateTime.t`, *default:* `nil`) - Output only. Time when the link was created.
*   `dailyExportEnabled` (*type:* `boolean()`, *default:* `nil`) - If set true, enables daily data export to the linked Google Cloud project.
*   `datasetLocation` (*type:* `String.t`, *default:* `nil`) - Required. Immutable. The geographic location where the created BigQuery dataset should reside. See https://cloud.google.com/bigquery/docs/locations for supported locations.
*   `excludedEvents` (*type:* `list(String.t)`, *default:* `nil`) - The list of event names that will be excluded from exports.
*   `exportStreams` (*type:* `list(String.t)`, *default:* `nil`) - The list of streams under the parent property for which data will be exported. Format: properties/{property_id}/dataStreams/{stream_id} Example: ['properties/1000/dataStreams/2000']
*   `freshDailyExportEnabled` (*type:* `boolean()`, *default:* `nil`) - If set true, enables fresh daily export to the linked Google Cloud project.
*   `includeAdvertisingId` (*type:* `boolean()`, *default:* `nil`) - If set true, exported data will include advertising identifiers for mobile app streams.
*   `name` (*type:* `String.t`, *default:* `nil`) - Output only. Resource name of this BigQuery link. Format: 'properties/{property_id}/bigQueryLinks/{bigquery_link_id}' Format: 'properties/1234/bigQueryLinks/abc567'
*   `project` (*type:* `String.t`, *default:* `nil`) - Immutable. The linked Google Cloud project. When creating a BigQueryLink, you may provide this resource name using either a project number or project ID. Once this resource has been created, the returned project will always have a project that contains a project number. Format: 'projects/{project number}' Example: 'projects/1234'
*   `streamingExportEnabled` (*type:* `boolean()`, *default:* `nil`) - If set true, enables streaming export to the linked Google Cloud project.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.