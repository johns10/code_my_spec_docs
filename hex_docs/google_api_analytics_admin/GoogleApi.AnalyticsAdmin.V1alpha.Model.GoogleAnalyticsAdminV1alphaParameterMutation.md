# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaParameterMutation

Defines an event parameter to mutate.

## Attributes

*   `parameter` (*type:* `String.t`, *default:* `nil`) - Required. The name of the parameter to mutate. This value must: * be less than 40 characters. * be unique across across all mutations within the rule * consist only of letters, digits or _ (underscores) For event edit rules, the name may also be set to 'event_name' to modify the event_name in place.
*   `parameterValue` (*type:* `String.t`, *default:* `nil`) - Required. The value mutation to perform. * Must be less than 100 characters. * To specify a constant value for the param, use the value's string. * To copy value from another parameter, use syntax like "[[other_parameter]]" For more details, see this [help center article](https://support.google.com/analytics/answer/10085872#modify-an-event&zippy=%2Cin-this-article%2Cmodify-parameters).

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.