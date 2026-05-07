# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaEventCreateRule

An Event Create Rule defines conditions that will trigger the creation of an entirely new event based upon matched criteria of a source event. Additional mutations of the parameters from the source event can be defined. Unlike Event Edit rules, Event Creation Rules have no defined order. They will all be run independently. Event Edit and Event Create rules can't be used to modify an event created from an Event Create rule.

## Attributes

*   `destinationEvent` (*type:* `String.t`, *default:* `nil`) - Required. The name of the new event to be created. This value must: * be less than 40 characters * consist only of letters, digits or _ (underscores) * start with a letter
*   `eventConditions` (*type:* `list(GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaMatchingCondition.t)`, *default:* `nil`) - Required. Must have at least one condition, and can have up to 10 max. Conditions on the source event must match for this rule to be applied.
*   `name` (*type:* `String.t`, *default:* `nil`) - Output only. Resource name for this EventCreateRule resource. Format: properties/{property}/dataStreams/{data_stream}/eventCreateRules/{event_create_rule}
*   `parameterMutations` (*type:* `list(GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaParameterMutation.t)`, *default:* `nil`) - Parameter mutations define parameter behavior on the new event, and are applied in order. A maximum of 20 mutations can be applied.
*   `sourceCopyParameters` (*type:* `boolean()`, *default:* `nil`) - If true, the source parameters are copied to the new event. If false, or unset, all non-internal parameters are not copied from the source event. Parameter mutations are applied after the parameters have been copied.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.