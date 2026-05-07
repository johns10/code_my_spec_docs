# GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaAccessDimensionHeader

Describes a dimension column in the report. Dimensions requested in a report produce column entries within rows and DimensionHeaders. However, dimensions used exclusively within filters or expressions do not produce columns in a report; correspondingly, those dimensions do not produce headers.

## Attributes

*   `dimensionName` (*type:* `String.t`, *default:* `nil`) - The dimension's name; for example 'userEmail'.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.