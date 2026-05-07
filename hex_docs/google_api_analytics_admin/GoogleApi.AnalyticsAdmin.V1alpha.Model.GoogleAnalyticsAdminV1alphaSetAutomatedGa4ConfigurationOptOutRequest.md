# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaSetAutomatedGa4ConfigurationOptOutRequest

Request for setting the opt out status for the automated GA4 setup process.

## Attributes

*   `optOut` (*type:* `boolean()`, *default:* `nil`) - The status to set.
*   `property` (*type:* `String.t`, *default:* `nil`) - Required. The UA property to set the opt out status. Note this request uses the internal property ID, not the tracking ID of the form UA-XXXXXX-YY. Format: properties/{internalWebPropertyId} Example: properties/1234

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.