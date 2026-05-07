# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaSKAdNetworkConversionValueSchema

SKAdNetwork conversion value schema of an iOS stream.

## Attributes

*   `applyConversionValues` (*type:* `boolean()`, *default:* `nil`) - If enabled, the GA SDK will set conversion values using this schema definition, and schema will be exported to any Google Ads accounts linked to this property. If disabled, the GA SDK will not automatically set conversion values, and also the schema will not be exported to Ads.
*   `name` (*type:* `String.t`, *default:* `nil`) - Output only. Resource name of the schema. This will be child of ONLY an iOS stream, and there can be at most one such child under an iOS stream. Format: properties/{property}/dataStreams/{dataStream}/sKAdNetworkConversionValueSchema
*   `postbackWindowOne` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaPostbackWindow.t`, *default:* `nil`) - Required. The conversion value settings for the first postback window. These differ from values for postback window two and three in that they contain a "Fine" grained conversion value (a numeric value). Conversion values for this postback window must be set. The other windows are optional and may inherit this window's settings if unset or disabled.
*   `postbackWindowThree` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaPostbackWindow.t`, *default:* `nil`) - The conversion value settings for the third postback window. This field should only be set if the user chose to define different conversion values for this postback window. It is allowed to configure window 3 without setting window 2. In case window 1 & 2 settings are set and enable_postback_window_settings for this postback window is set to false, the schema will inherit settings from postback_window_two.
*   `postbackWindowTwo` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaPostbackWindow.t`, *default:* `nil`) - The conversion value settings for the second postback window. This field should only be configured if there is a need to define different conversion values for this postback window. If enable_postback_window_settings is set to false for this postback window, the values from postback_window_one will be used.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.