# GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaGoogleAdsLink

A link between a Google Analytics property and a Google Ads account.

## Attributes

*   `adsPersonalizationEnabled` (*type:* `boolean()`, *default:* `nil`) - Enable personalized advertising features with this integration. Automatically publish my Google Analytics audience lists and Google Analytics remarketing events/parameters to the linked Google Ads account. If this field is not set on create/update, it will be defaulted to true.
*   `canManageClients` (*type:* `boolean()`, *default:* `nil`) - Output only. If true, this link is for a Google Ads manager account.
*   `createTime` (*type:* `DateTime.t`, *default:* `nil`) - Output only. Time when this link was originally created.
*   `creatorEmailAddress` (*type:* `String.t`, *default:* `nil`) - Output only. Email address of the user that created the link. An empty string will be returned if the email address can't be retrieved.
*   `customerId` (*type:* `String.t`, *default:* `nil`) - Immutable. Google Ads customer ID.
*   `name` (*type:* `String.t`, *default:* `nil`) - Output only. Format: properties/{propertyId}/googleAdsLinks/{googleAdsLinkId} Note: googleAdsLinkId is not the Google Ads customer ID.
*   `updateTime` (*type:* `DateTime.t`, *default:* `nil`) - Output only. Time when this link was last updated.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.