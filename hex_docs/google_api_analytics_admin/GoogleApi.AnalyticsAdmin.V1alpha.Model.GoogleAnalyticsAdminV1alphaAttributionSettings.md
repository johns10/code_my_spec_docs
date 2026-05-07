# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAttributionSettings

The attribution settings used for a given property. This is a singleton resource.

## Attributes

*   `acquisitionConversionEventLookbackWindow` (*type:* `String.t`, *default:* `nil`) - Required. The lookback window configuration for acquisition conversion events. The default window size is 30 days.
*   `adsWebConversionDataExportScope` (*type:* `String.t`, *default:* `nil`) - Required. The Conversion Export Scope for data exported to linked Ads Accounts.
*   `name` (*type:* `String.t`, *default:* `nil`) - Output only. Resource name of this attribution settings resource. Format: properties/{property_id}/attributionSettings Example: "properties/1000/attributionSettings"
*   `otherConversionEventLookbackWindow` (*type:* `String.t`, *default:* `nil`) - Required. The lookback window for all other, non-acquisition conversion events. The default window size is 90 days.
*   `reportingAttributionModel` (*type:* `String.t`, *default:* `nil`) - Required. The reporting attribution model used to calculate conversion credit in this property's reports. Changing the attribution model will apply to both historical and future data. These changes will be reflected in reports with conversion and revenue data. User and session data will be unaffected.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.