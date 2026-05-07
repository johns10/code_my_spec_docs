# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaSubpropertyEventFilterClause

A clause for defining a filter. A filter may be inclusive (events satisfying the filter clause are included in the subproperty's data) or exclusive (events satisfying the filter clause are excluded from the subproperty's data).

## Attributes

*   `filterClauseType` (*type:* `String.t`, *default:* `nil`) - Required. The type for the filter clause.
*   `filterExpression` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaSubpropertyEventFilterExpression.t`, *default:* `nil`) - Required. The logical expression for what events are sent to the subproperty.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.