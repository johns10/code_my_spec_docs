# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaSearchAds360Link

A link between a Google Analytics property and a Search Ads 360 entity.

## Attributes

*   `adsPersonalizationEnabled` (*type:* `boolean()`, *default:* `nil`) - Enables personalized advertising features with this integration. If this field is not set on create, it will be defaulted to true.
*   `advertiserDisplayName` (*type:* `String.t`, *default:* `nil`) - Output only. The display name of the Search Ads 360 Advertiser. Allows users to easily identify the linked resource.
*   `advertiserId` (*type:* `String.t`, *default:* `nil`) - Immutable. This field represents the Advertiser ID of the Search Ads 360 Advertiser. that has been linked.
*   `campaignDataSharingEnabled` (*type:* `boolean()`, *default:* `nil`) - Immutable. Enables the import of campaign data from Search Ads 360 into the Google Analytics property. After link creation, this can only be updated from the Search Ads 360 product. If this field is not set on create, it will be defaulted to true.
*   `costDataSharingEnabled` (*type:* `boolean()`, *default:* `nil`) - Immutable. Enables the import of cost data from Search Ads 360 to the Google Analytics property. This can only be enabled if campaign_data_sharing_enabled is enabled. After link creation, this can only be updated from the Search Ads 360 product. If this field is not set on create, it will be defaulted to true.
*   `name` (*type:* `String.t`, *default:* `nil`) - Output only. The resource name for this SearchAds360Link resource. Format: properties/{propertyId}/searchAds360Links/{linkId} Note: linkId is not the Search Ads 360 advertiser ID
*   `siteStatsSharingEnabled` (*type:* `boolean()`, *default:* `nil`) - Enables export of site stats with this integration. If this field is not set on create, it will be defaulted to true.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.