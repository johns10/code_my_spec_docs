# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaDataRetentionSettings

Settings values for data retention. This is a singleton resource.

## Attributes

*   `eventDataRetention` (*type:* `String.t`, *default:* `nil`) - Required. The length of time that event-level data is retained.
*   `name` (*type:* `String.t`, *default:* `nil`) - Output only. Resource name for this DataRetentionSetting resource. Format: properties/{property}/dataRetentionSettings
*   `resetUserDataOnNewActivity` (*type:* `boolean()`, *default:* `nil`) - If true, reset the retention period for the user identifier with every event from that user.
*   `userDataRetention` (*type:* `String.t`, *default:* `nil`) - Required. The length of time that user-level data is retained.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.