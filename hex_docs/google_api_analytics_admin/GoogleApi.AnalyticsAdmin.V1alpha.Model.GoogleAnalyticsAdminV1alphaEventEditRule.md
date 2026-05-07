# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaEventEditRule

An Event Edit Rule defines conditions that will trigger the creation of an entirely new event based upon matched criteria of a source event. Additional mutations of the parameters from the source event can be defined. Unlike Event Create rules, Event Edit Rules are applied in their defined order. Event Edit rules can't be used to modify an event created from an Event Create rule.

## Attributes

*   `displayName` (*type:* `String.t`, *default:* `nil`) - Required. The display name of this event edit rule. Maximum of 255 characters.
*   `eventConditions` (*type:* `list(GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaMatchingCondition.t)`, *default:* `nil`) - Required. Conditions on the source event must match for this rule to be applied. Must have at least one condition, and can have up to 10 max.
*   `name` (*type:* `String.t`, *default:* `nil`) - Identifier. Resource name for this EventEditRule resource. Format: properties/{property}/dataStreams/{data_stream}/eventEditRules/{event_edit_rule}
*   `parameterMutations` (*type:* `list(GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaParameterMutation.t)`, *default:* `nil`) - Required. Parameter mutations define parameter behavior on the new event, and are applied in order. A maximum of 20 mutations can be applied.
*   `processingOrder` (*type:* `String.t`, *default:* `nil`) - Output only. The order for which this rule will be processed. Rules with an order value lower than this will be processed before this rule, rules with an order value higher than this will be processed after this rule. New event edit rules will be assigned an order value at the end of the order. This value does not apply to event create rules.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.