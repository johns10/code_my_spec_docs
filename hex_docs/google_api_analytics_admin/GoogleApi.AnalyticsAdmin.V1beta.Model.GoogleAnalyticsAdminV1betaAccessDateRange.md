# GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaAccessDateRange

A contiguous range of days: startDate, startDate + 1, ..., endDate.

## Attributes

*   `endDate` (*type:* `String.t`, *default:* `nil`) - The inclusive end date for the query in the format `YYYY-MM-DD`. Cannot be before `startDate`. The format `NdaysAgo`, `yesterday`, or `today` is also accepted, and in that case, the date is inferred based on the current time in the request's time zone.
*   `startDate` (*type:* `String.t`, *default:* `nil`) - The inclusive start date for the query in the format `YYYY-MM-DD`. Cannot be after `endDate`. The format `NdaysAgo`, `yesterday`, or `today` is also accepted, and in that case, the date is inferred based on the current time in the request's time zone.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.