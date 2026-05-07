# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAudienceEventFilter

A filter that matches events of a single event name. If an event parameter is specified, only the subset of events that match both the single event name and the parameter filter expressions match this event filter.

## Attributes

*   `eventName` (*type:* `String.t`, *default:* `nil`) - Required. Immutable. The name of the event to match against.
*   `eventParameterFilterExpression` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAudienceFilterExpression.t`, *default:* `nil`) - Optional. If specified, this filter matches events that match both the single event name and the parameter filter expressions. AudienceEventFilter inside the parameter filter expression cannot be set (For example, nested event filters are not supported). This should be a single and_group of dimension_or_metric_filter or not_expression; ANDs of ORs are not supported. Also, if it includes a filter for "eventCount", only that one will be considered; all the other filters will be ignored.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.