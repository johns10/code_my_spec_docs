# GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaAccessDimension

Dimensions are attributes of your data. For example, the dimension `userEmail` indicates the email of the user that accessed reporting data. Dimension values in report responses are strings.

## Attributes

*   `dimensionName` (*type:* `String.t`, *default:* `nil`) - The API name of the dimension. See [Data Access Schema](https://developers.google.com/analytics/devguides/config/admin/v1/access-api-schema) for the list of dimensions supported in this API. Dimensions are referenced by name in `dimensionFilter` and `orderBys`.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.