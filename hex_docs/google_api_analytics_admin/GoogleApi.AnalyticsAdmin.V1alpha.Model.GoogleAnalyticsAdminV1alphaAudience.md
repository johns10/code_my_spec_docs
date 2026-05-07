# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAudience

A resource message representing an Audience.

## Attributes

*   `adsPersonalizationEnabled` (*type:* `boolean()`, *default:* `nil`) - Output only. It is automatically set by GA to false if this is an NPA Audience and is excluded from ads personalization.
*   `createTime` (*type:* `DateTime.t`, *default:* `nil`) - Output only. Time when the Audience was created.
*   `description` (*type:* `String.t`, *default:* `nil`) - Required. The description of the Audience.
*   `displayName` (*type:* `String.t`, *default:* `nil`) - Required. The display name of the Audience.
*   `eventTrigger` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAudienceEventTrigger.t`, *default:* `nil`) - Optional. Specifies an event to log when a user joins the Audience. If not set, no event is logged when a user joins the Audience.
*   `exclusionDurationMode` (*type:* `String.t`, *default:* `nil`) - Immutable. Specifies how long an exclusion lasts for users that meet the exclusion filter. It is applied to all EXCLUDE filter clauses and is ignored when there is no EXCLUDE filter clause in the Audience.
*   `filterClauses` (*type:* `list(GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAudienceFilterClause.t)`, *default:* `nil`) - Required. Immutable. Unordered list. Filter clauses that define the Audience. All clauses will be AND’ed together.
*   `membershipDurationDays` (*type:* `integer()`, *default:* `nil`) - Required. Immutable. The duration a user should stay in an Audience. It cannot be set to more than 540 days.
*   `name` (*type:* `String.t`, *default:* `nil`) - Output only. The resource name for this Audience resource. Format: properties/{propertyId}/audiences/{audienceId}

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.