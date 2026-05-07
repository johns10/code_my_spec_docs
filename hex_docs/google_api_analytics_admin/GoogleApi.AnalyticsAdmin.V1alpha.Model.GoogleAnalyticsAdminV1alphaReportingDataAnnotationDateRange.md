# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaReportingDataAnnotationDateRange

Represents a Reporting Data Annotation's date range, both start and end dates are inclusive. Time zones are based on the parent property.

## Attributes

*   `endDate` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleTypeDate.t`, *default:* `nil`) - Required. The end date for this range. Must be a valid date with year, month, and day set. This date must be greater than or equal to the start date.
*   `startDate` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleTypeDate.t`, *default:* `nil`) - Required. The start date for this range. Must be a valid date with year, month, and day set. The date may be in the past, present, or future.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.