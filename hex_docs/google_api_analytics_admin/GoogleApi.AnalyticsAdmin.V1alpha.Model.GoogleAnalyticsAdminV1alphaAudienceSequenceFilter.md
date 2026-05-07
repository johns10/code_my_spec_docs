# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAudienceSequenceFilter

Defines filters that must occur in a specific order for the user to be a member of the Audience.

## Attributes

*   `scope` (*type:* `String.t`, *default:* `nil`) - Required. Immutable. Specifies the scope for this filter.
*   `sequenceMaximumDuration` (*type:* `String.t`, *default:* `nil`) - Optional. Defines the time period in which the whole sequence must occur.
*   `sequenceSteps` (*type:* `list(GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAudienceSequenceFilterAudienceSequenceStep.t)`, *default:* `nil`) - Required. An ordered sequence of steps. A user must complete each step in order to join the sequence filter.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.