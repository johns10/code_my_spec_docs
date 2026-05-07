# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaChannelGroup

A resource message representing a Channel Group.

## Attributes

*   `description` (*type:* `String.t`, *default:* `nil`) - The description of the Channel Group. Max length of 256 characters.
*   `displayName` (*type:* `String.t`, *default:* `nil`) - Required. The display name of the Channel Group. Max length of 80 characters.
*   `groupingRule` (*type:* `list(GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaGroupingRule.t)`, *default:* `nil`) - Required. The grouping rules of channels. Maximum number of rules is 50.
*   `name` (*type:* `String.t`, *default:* `nil`) - Output only. The resource name for this Channel Group resource. Format: properties/{property}/channelGroups/{channel_group}
*   `primary` (*type:* `boolean()`, *default:* `nil`) - Optional. If true, this channel group will be used as the default channel group for reports. Only one channel group can be set as `primary` at any time. If the `primary` field gets set on a channel group, it will get unset on the previous primary channel group. The Google Analytics predefined channel group is the primary by default.
*   `systemDefined` (*type:* `boolean()`, *default:* `nil`) - Output only. If true, then this channel group is the Default Channel Group predefined by Google Analytics. Display name and grouping rules cannot be updated for this channel group.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.