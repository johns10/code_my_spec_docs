# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaMatchingCondition

Defines a condition for when an Event Edit or Event Creation rule applies to an event.

## Attributes

*   `comparisonType` (*type:* `String.t`, *default:* `nil`) - Required. The type of comparison to be applied to the value.
*   `field` (*type:* `String.t`, *default:* `nil`) - Required. The name of the field that is compared against for the condition. If 'event_name' is specified this condition will apply to the name of the event. Otherwise the condition will apply to a parameter with the specified name. This value cannot contain spaces.
*   `negated` (*type:* `boolean()`, *default:* `nil`) - Whether or not the result of the comparison should be negated. For example, if `negated` is true, then 'equals' comparisons would function as 'not equals'.
*   `value` (*type:* `String.t`, *default:* `nil`) - Required. The value being compared against for this condition. The runtime implementation may perform type coercion of this value to evaluate this condition based on the type of the parameter value.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.