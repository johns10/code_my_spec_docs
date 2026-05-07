# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaListReportingDataAnnotationsResponse

Response message for ListReportingDataAnnotation RPC.

## Attributes

*   `nextPageToken` (*type:* `String.t`, *default:* `nil`) - A token, which can be sent as `page_token` to retrieve the next page. If this field is omitted, there are no subsequent pages.
*   `reportingDataAnnotations` (*type:* `list(GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaReportingDataAnnotation.t)`, *default:* `nil`) - List of Reporting Data Annotations.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.