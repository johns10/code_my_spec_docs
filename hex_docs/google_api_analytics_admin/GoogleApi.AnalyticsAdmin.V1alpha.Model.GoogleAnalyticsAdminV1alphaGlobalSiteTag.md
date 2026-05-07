# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaGlobalSiteTag

Read-only resource with the tag for sending data from a website to a DataStream. Only present for web DataStream resources.

## Attributes

*   `name` (*type:* `String.t`, *default:* `nil`) - Output only. Resource name for this GlobalSiteTag resource. Format: properties/{property_id}/dataStreams/{stream_id}/globalSiteTag Example: "properties/123/dataStreams/456/globalSiteTag"
*   `snippet` (*type:* `String.t`, *default:* `nil`) - Immutable. JavaScript code snippet to be pasted as the first item into the head tag of every webpage to measure.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.