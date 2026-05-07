# GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaDataStreamIosAppStreamData

Data specific to iOS app streams.

## Attributes

*   `bundleId` (*type:* `String.t`, *default:* `nil`) - Required. Immutable. The Apple App Store Bundle ID for the app Example: "com.example.myiosapp"
*   `firebaseAppId` (*type:* `String.t`, *default:* `nil`) - Output only. ID of the corresponding iOS app in Firebase, if any. This ID can change if the iOS app is deleted and recreated.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.