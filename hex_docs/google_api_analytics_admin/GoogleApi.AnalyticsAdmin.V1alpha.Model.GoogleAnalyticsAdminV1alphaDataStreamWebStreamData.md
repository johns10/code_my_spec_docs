# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaDataStreamWebStreamData

Data specific to web streams.

## Attributes

*   `defaultUri` (*type:* `String.t`, *default:* `nil`) - Domain name of the web app being measured, or empty. Example: "http://www.google.com", "https://www.google.com"
*   `firebaseAppId` (*type:* `String.t`, *default:* `nil`) - Output only. ID of the corresponding web app in Firebase, if any. This ID can change if the web app is deleted and recreated.
*   `measurementId` (*type:* `String.t`, *default:* `nil`) - Output only. Analytics Measurement ID. Example: "G-1A2BCD345E"

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.