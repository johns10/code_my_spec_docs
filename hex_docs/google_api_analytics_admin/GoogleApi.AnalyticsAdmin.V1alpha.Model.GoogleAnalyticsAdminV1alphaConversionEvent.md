# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaConversionEvent

A conversion event in a Google Analytics property.

## Attributes

*   `countingMethod` (*type:* `String.t`, *default:* `nil`) - Optional. The method by which conversions will be counted across multiple events within a session. If this value is not provided, it will be set to `ONCE_PER_EVENT`.
*   `createTime` (*type:* `DateTime.t`, *default:* `nil`) - Output only. Time when this conversion event was created in the property.
*   `custom` (*type:* `boolean()`, *default:* `nil`) - Output only. If set to true, this conversion event refers to a custom event. If set to false, this conversion event refers to a default event in GA. Default events typically have special meaning in GA. Default events are usually created for you by the GA system, but in some cases can be created by property admins. Custom events count towards the maximum number of custom conversion events that may be created per property.
*   `defaultConversionValue` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaConversionEventDefaultConversionValue.t`, *default:* `nil`) - Optional. Defines a default value/currency for a conversion event.
*   `deletable` (*type:* `boolean()`, *default:* `nil`) - Output only. If set, this event can currently be deleted with DeleteConversionEvent.
*   `eventName` (*type:* `String.t`, *default:* `nil`) - Immutable. The event name for this conversion event. Examples: 'click', 'purchase'
*   `name` (*type:* `String.t`, *default:* `nil`) - Output only. Resource name of this conversion event. Format: properties/{property}/conversionEvents/{conversion_event}

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.