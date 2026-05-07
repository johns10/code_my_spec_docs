# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaConversionEventDefaultConversionValue

Defines a default value/currency for a conversion event. Both value and currency must be provided.

## Attributes

*   `currencyCode` (*type:* `String.t`, *default:* `nil`) - When a conversion event for this event_name has no set currency, this currency will be applied as the default. Must be in ISO 4217 currency code format. See https://en.wikipedia.org/wiki/ISO_4217 for more information.
*   `value` (*type:* `float()`, *default:* `nil`) - This value will be used to populate the value for all conversions of the specified event_name where the event "value" parameter is unset.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.