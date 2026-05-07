# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaDisplayVideo360AdvertiserLink

A link between a Google Analytics property and a Display & Video 360 advertiser.

## Attributes

*   `adsPersonalizationEnabled` (*type:* `boolean()`, *default:* `nil`) - Enables personalized advertising features with this integration. If this field is not set on create/update, it will be defaulted to true.
*   `advertiserDisplayName` (*type:* `String.t`, *default:* `nil`) - Output only. The display name of the Display & Video 360 Advertiser.
*   `advertiserId` (*type:* `String.t`, *default:* `nil`) - Immutable. The Display & Video 360 Advertiser's advertiser ID.
*   `campaignDataSharingEnabled` (*type:* `boolean()`, *default:* `nil`) - Immutable. Enables the import of campaign data from Display & Video 360 into the Google Analytics property. After link creation, this can only be updated from the Display & Video 360 product. If this field is not set on create, it will be defaulted to true.
*   `costDataSharingEnabled` (*type:* `boolean()`, *default:* `nil`) - Immutable. Enables the import of cost data from Display & Video 360 into the Google Analytics property. This can only be enabled if `campaign_data_sharing_enabled` is true. After link creation, this can only be updated from the Display & Video 360 product. If this field is not set on create, it will be defaulted to true.
*   `name` (*type:* `String.t`, *default:* `nil`) - Output only. The resource name for this DisplayVideo360AdvertiserLink resource. Format: properties/{propertyId}/displayVideo360AdvertiserLinks/{linkId} Note: linkId is not the Display & Video 360 Advertiser ID

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.