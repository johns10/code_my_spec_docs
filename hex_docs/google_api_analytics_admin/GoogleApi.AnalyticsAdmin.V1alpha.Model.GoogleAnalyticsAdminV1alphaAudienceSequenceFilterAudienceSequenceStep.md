# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAudienceSequenceFilterAudienceSequenceStep

A condition that must occur in the specified step order for this user to match the sequence.

## Attributes

*   `constraintDuration` (*type:* `String.t`, *default:* `nil`) - Optional. When set, this step must be satisfied within the constraint_duration of the previous step (For example, t[i] - t[i-1] <= constraint_duration). If not set, there is no duration requirement (the duration is effectively unlimited). It is ignored for the first step.
*   `filterExpression` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAudienceFilterExpression.t`, *default:* `nil`) - Required. Immutable. A logical expression of Audience dimension, metric, or event filters in each step.
*   `immediatelyFollows` (*type:* `boolean()`, *default:* `nil`) - Optional. If true, the event satisfying this step must be the very next event after the event satisfying the last step. If unset or false, this step indirectly follows the prior step; for example, there may be events between the prior step and this step. It is ignored for the first step.
*   `scope` (*type:* `String.t`, *default:* `nil`) - Required. Immutable. Specifies the scope for this step.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.