# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAudienceDimensionOrMetricFilter

A specific filter for a single dimension or metric.

## Attributes

*   `atAnyPointInTime` (*type:* `boolean()`, *default:* `nil`) - Optional. Indicates whether this filter needs dynamic evaluation or not. If set to true, users join the Audience if they ever met the condition (static evaluation). If unset or set to false, user evaluation for an Audience is dynamic; users are added to an Audience when they meet the conditions and then removed when they no longer meet them. This can only be set when Audience scope is ACROSS_ALL_SESSIONS.
*   `betweenFilter` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAudienceDimensionOrMetricFilterBetweenFilter.t`, *default:* `nil`) - A filter for numeric or date values between certain values on a dimension or metric.
*   `fieldName` (*type:* `String.t`, *default:* `nil`) - Required. Immutable. The dimension name or metric name to filter. If the field name refers to a custom dimension or metric, a scope prefix will be added to the front of the custom dimensions or metric name. For more on scope prefixes or custom dimensions/metrics, reference the [Google Analytics Data API documentation] (https://developers.google.com/analytics/devguides/reporting/data/v1/api-schema#custom_dimensions).
*   `inAnyNDayPeriod` (*type:* `integer()`, *default:* `nil`) - Optional. If set, specifies the time window for which to evaluate data in number of days. If not set, then audience data is evaluated against lifetime data (For example, infinite time window). For example, if set to 1 day, only the current day's data is evaluated. The reference point is the current day when at_any_point_in_time is unset or false. It can only be set when Audience scope is ACROSS_ALL_SESSIONS and cannot be greater than 60 days.
*   `inListFilter` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAudienceDimensionOrMetricFilterInListFilter.t`, *default:* `nil`) - A filter for a string dimension that matches a particular list of options.
*   `numericFilter` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAudienceDimensionOrMetricFilterNumericFilter.t`, *default:* `nil`) - A filter for numeric or date values on a dimension or metric.
*   `stringFilter` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAudienceDimensionOrMetricFilterStringFilter.t`, *default:* `nil`) - A filter for a string-type dimension that matches a particular pattern.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.