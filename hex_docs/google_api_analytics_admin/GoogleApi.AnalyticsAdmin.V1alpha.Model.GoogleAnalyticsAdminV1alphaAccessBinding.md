# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaAccessBinding

A binding of a user to a set of roles.

## Attributes

*   `name` (*type:* `String.t`, *default:* `nil`) - Output only. Resource name of this binding. Format: accounts/{account}/accessBindings/{access_binding} or properties/{property}/accessBindings/{access_binding} Example: "accounts/100/accessBindings/200"
*   `roles` (*type:* `list(String.t)`, *default:* `nil`) - A list of roles for to grant to the parent resource. Valid values: predefinedRoles/viewer predefinedRoles/analyst predefinedRoles/editor predefinedRoles/admin predefinedRoles/no-cost-data predefinedRoles/no-revenue-data For users, if an empty list of roles is set, this AccessBinding will be deleted.
*   `user` (*type:* `String.t`, *default:* `nil`) - If set, the email address of the user to set roles for. Format: "someuser@gmail.com"

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.