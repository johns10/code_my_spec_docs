# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAccountSummary

A virtual resource representing an overview of an account and all its child Google Analytics properties.

## Attributes

*   `account` (*type:* `String.t`, *default:* `nil`) - Resource name of account referred to by this account summary Format: accounts/{account_id} Example: "accounts/1000"
*   `displayName` (*type:* `String.t`, *default:* `nil`) - Display name for the account referred to in this account summary.
*   `name` (*type:* `String.t`, *default:* `nil`) - Resource name for this account summary. Format: accountSummaries/{account_id} Example: "accountSummaries/1000"
*   `propertySummaries` (*type:* `list(GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaPropertySummary.t)`, *default:* `nil`) - List of summaries for child accounts of this account.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.