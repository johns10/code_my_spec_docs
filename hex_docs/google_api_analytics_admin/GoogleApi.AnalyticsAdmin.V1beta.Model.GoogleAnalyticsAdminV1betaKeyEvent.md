# GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaKeyEvent

A key event in a Google Analytics property.

## Attributes

*   `countingMethod` (*type:* `String.t`, *default:* `nil`) - Required. The method by which Key Events will be counted across multiple events within a session.
*   `createTime` (*type:* `DateTime.t`, *default:* `nil`) - Output only. Time when this key event was created in the property.
*   `custom` (*type:* `boolean()`, *default:* `nil`) - Output only. If set to true, this key event refers to a custom event. If set to false, this key event refers to a default event in GA. Default events typically have special meaning in GA. Default events are usually created for you by the GA system, but in some cases can be created by property admins. Custom events count towards the maximum number of custom key events that may be created per property.
*   `defaultValue` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaKeyEventDefaultValue.t`, *default:* `nil`) - Optional. Defines a default value/currency for a key event.
*   `deletable` (*type:* `boolean()`, *default:* `nil`) - Output only. If set to true, this event can be deleted.
*   `eventName` (*type:* `String.t`, *default:* `nil`) - Immutable. The event name for this key event. Examples: 'click', 'purchase'
*   `name` (*type:* `String.t`, *default:* `nil`) - Output only. Resource name of this key event. Format: properties/{property}/keyEvents/{key_event}

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.