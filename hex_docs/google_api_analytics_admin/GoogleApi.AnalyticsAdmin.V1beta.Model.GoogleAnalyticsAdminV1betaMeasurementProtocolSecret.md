# GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaMeasurementProtocolSecret

A secret value used for sending hits to Measurement Protocol.

## Attributes

*   `displayName` (*type:* `String.t`, *default:* `nil`) - Required. Human-readable display name for this secret.
*   `name` (*type:* `String.t`, *default:* `nil`) - Output only. Resource name of this secret. This secret may be a child of any type of stream. Format: properties/{property}/dataStreams/{dataStream}/measurementProtocolSecrets/{measurementProtocolSecret}
*   `secretValue` (*type:* `String.t`, *default:* `nil`) - Output only. The measurement protocol secret value. Pass this value to the api_secret field of the Measurement Protocol API when sending hits to this secret's parent property.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.