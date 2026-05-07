# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaKeyEventDefaultValue

Defines a default value/currency for a key event.

## Attributes

*   `currencyCode` (*type:* `String.t`, *default:* `nil`) - Required. When an occurrence of this Key Event (specified by event_name) has no set currency this currency will be applied as the default. Must be in ISO 4217 currency code format. See https://en.wikipedia.org/wiki/ISO_4217 for more information.
*   `numericValue` (*type:* `float()`, *default:* `nil`) - Required. This will be used to populate the "value" parameter for all occurrences of this Key Event (specified by event_name) where that parameter is unset.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.