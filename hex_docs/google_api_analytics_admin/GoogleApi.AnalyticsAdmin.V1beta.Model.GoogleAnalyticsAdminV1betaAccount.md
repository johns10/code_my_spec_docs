# GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaAccount

A resource message representing a Google Analytics account.

## Attributes

*   `createTime` (*type:* `DateTime.t`, *default:* `nil`) - Output only. Time when this account was originally created.
*   `deleted` (*type:* `boolean()`, *default:* `nil`) - Output only. Indicates whether this Account is soft-deleted or not. Deleted accounts are excluded from List results unless specifically requested.
*   `displayName` (*type:* `String.t`, *default:* `nil`) - Required. Human-readable display name for this account.
*   `gmpOrganization` (*type:* `String.t`, *default:* `nil`) - Output only. The URI for a Google Marketing Platform organization resource. Only set when this account is connected to a GMP organization. Format: marketingplatformadmin.googleapis.com/organizations/{org_id}
*   `name` (*type:* `String.t`, *default:* `nil`) - Output only. Resource name of this account. Format: accounts/{account} Example: "accounts/100"
*   `regionCode` (*type:* `String.t`, *default:* `nil`) - Country of business. Must be a Unicode CLDR region code.
*   `updateTime` (*type:* `DateTime.t`, *default:* `nil`) - Output only. Time when account payload fields were last updated.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.