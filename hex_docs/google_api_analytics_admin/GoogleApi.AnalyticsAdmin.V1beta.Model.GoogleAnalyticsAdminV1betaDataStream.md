# GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaDataStream

A resource message representing a data stream.

## Attributes

*   `androidAppStreamData` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaDataStreamAndroidAppStreamData.t`, *default:* `nil`) - Data specific to Android app streams. Must be populated if type is ANDROID_APP_DATA_STREAM.
*   `createTime` (*type:* `DateTime.t`, *default:* `nil`) - Output only. Time when this stream was originally created.
*   `displayName` (*type:* `String.t`, *default:* `nil`) - Human-readable display name for the Data Stream. Required for web data streams. The max allowed display name length is 255 UTF-16 code units.
*   `iosAppStreamData` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaDataStreamIosAppStreamData.t`, *default:* `nil`) - Data specific to iOS app streams. Must be populated if type is IOS_APP_DATA_STREAM.
*   `name` (*type:* `String.t`, *default:* `nil`) - Output only. Resource name of this Data Stream. Format: properties/{property_id}/dataStreams/{stream_id} Example: "properties/1000/dataStreams/2000"
*   `type` (*type:* `String.t`, *default:* `nil`) - Required. Immutable. The type of this DataStream resource.
*   `updateTime` (*type:* `DateTime.t`, *default:* `nil`) - Output only. Time when stream payload fields were last updated.
*   `webStreamData` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaDataStreamWebStreamData.t`, *default:* `nil`) - Data specific to web streams. Must be populated if type is WEB_DATA_STREAM.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.