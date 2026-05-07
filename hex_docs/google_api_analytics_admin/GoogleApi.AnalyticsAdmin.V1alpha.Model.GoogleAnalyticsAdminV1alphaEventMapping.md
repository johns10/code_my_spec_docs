# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaEventMapping

Event setting conditions to match an event.

## Attributes

*   `eventName` (*type:* `String.t`, *default:* `nil`) - Required. Name of the Google Analytics event. It must always be set. The max allowed display name length is 40 UTF-16 code units.
*   `maxEventCount` (*type:* `String.t`, *default:* `nil`) - The maximum number of times the event occurred. If not set, maximum event count won't be checked.
*   `maxEventValue` (*type:* `float()`, *default:* `nil`) - The maximum revenue generated due to the event. Revenue currency will be defined at the property level. If not set, maximum event value won't be checked.
*   `minEventCount` (*type:* `String.t`, *default:* `nil`) - At least one of the following four min/max values must be set. The values set will be ANDed together to qualify an event. The minimum number of times the event occurred. If not set, minimum event count won't be checked.
*   `minEventValue` (*type:* `float()`, *default:* `nil`) - The minimum revenue generated due to the event. Revenue currency will be defined at the property level. If not set, minimum event value won't be checked.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.