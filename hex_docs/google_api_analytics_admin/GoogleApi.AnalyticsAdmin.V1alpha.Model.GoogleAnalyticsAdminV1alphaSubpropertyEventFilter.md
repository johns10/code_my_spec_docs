# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaSubpropertyEventFilter

A resource message representing a Google Analytics subproperty event filter.

## Attributes

*   `applyToProperty` (*type:* `String.t`, *default:* `nil`) - Immutable. Resource name of the Subproperty that uses this filter.
*   `filterClauses` (*type:* `list(GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaSubpropertyEventFilterClause.t)`, *default:* `nil`) - Required. Unordered list. Filter clauses that define the SubpropertyEventFilter. All clauses are AND'ed together to determine what data is sent to the subproperty.
*   `name` (*type:* `String.t`, *default:* `nil`) - Output only. Format: properties/{ordinary_property_id}/subpropertyEventFilters/{sub_property_event_filter} Example: properties/1234/subpropertyEventFilters/5678

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.