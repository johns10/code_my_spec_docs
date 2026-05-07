# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaFetchAutomatedGa4ConfigurationOptOutRequest

Request for fetching the opt out status for the automated GA4 setup process.

## Attributes

*   `property` (*type:* `String.t`, *default:* `nil`) - Required. The UA property to get the opt out status. Note this request uses the internal property ID, not the tracking ID of the form UA-XXXXXX-YY. Format: properties/{internalWebPropertyId} Example: properties/1234

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.