# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAudienceFilterClause

A clause for defining either a simple or sequence filter. A filter can be inclusive (For example, users satisfying the filter clause are included in the Audience) or exclusive (For example, users satisfying the filter clause are excluded from the Audience).

## Attributes

*   `clauseType` (*type:* `String.t`, *default:* `nil`) - Required. Specifies whether this is an include or exclude filter clause.
*   `sequenceFilter` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAudienceSequenceFilter.t`, *default:* `nil`) - Filters that must occur in a specific order for the user to be a member of the Audience.
*   `simpleFilter` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAudienceSimpleFilter.t`, *default:* `nil`) - A simple filter that a user must satisfy to be a member of the Audience.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.