# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaProvisionAccountTicketRequest

Request message for ProvisionAccountTicket RPC.

## Attributes

*   `account` (*type:* `GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAccount.t`, *default:* `nil`) - The account to create.
*   `redirectUri` (*type:* `String.t`, *default:* `nil`) - Redirect URI where the user will be sent after accepting Terms of Service. Must be configured in Cloud Console as a Redirect URI.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.