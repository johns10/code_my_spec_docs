# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaDisplayVideo360AdvertiserLinkProposal

A proposal for a link between a Google Analytics property and a Display & Video 360 advertiser. A proposal is converted to a DisplayVideo360AdvertiserLink once approved. Google Analytics admins approve inbound proposals while Display & Video 360 admins approve outbound proposals.

## Attributes

*   `adsPersonalizationEnabled` (*type:* `boolean()`, *default:* `nil`) - Immutable. Enables personalized advertising features with this integration. If this field is not set on create, it will be defaulted to true.
*   `advertiserDisplayName` (*type:* `String.t`, *default:* `nil`) - Output only. The display name of the Display & Video Advertiser. Only populated for proposals that originated from Display & Video 360.
*   `advertiserId` (*type:* `String.t`, *default:* `nil`) - Immutable. The Display & Video 360 Advertiser's advertiser ID.
*   `campaignDataSharingEnabled` (*type:* `boolean()`, *default:* `nil`) - Immutable. Enables the import of campaign data from Display & Video 360. If this field is not set on create, it will be defaulted to true.
*   `costDataSharingEnabled` (*type:* `boolean()`, *default:* `nil`) - Immutable. Enables the import of cost data from Display & Video 360. This can only be enabled if campaign_data_sharing_enabled is enabled. If this field is not set on create, it will be defaulted to true.
*   `linkProposalStatusDetails` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaLinkProposalStatusDetails.t`, *default:* `nil`) - Output only. The status information for this link proposal.
*   `name` (*type:* `String.t`, *default:* `nil`) - Output only. The resource name for this DisplayVideo360AdvertiserLinkProposal resource. Format: properties/{propertyId}/displayVideo360AdvertiserLinkProposals/{proposalId} Note: proposalId is not the Display & Video 360 Advertiser ID
*   `validationEmail` (*type:* `String.t`, *default:* `nil`) - Input only. On a proposal being sent to Display & Video 360, this field must be set to the email address of an admin on the target advertiser. This is used to verify that the Google Analytics admin is aware of at least one admin on the Display & Video 360 Advertiser. This does not restrict approval of the proposal to a single user. Any admin on the Display & Video 360 Advertiser may approve the proposal.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.