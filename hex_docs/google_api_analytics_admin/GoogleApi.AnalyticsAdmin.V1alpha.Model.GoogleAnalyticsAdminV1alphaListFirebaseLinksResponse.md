# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaListFirebaseLinksResponse

Response message for ListFirebaseLinks RPC

## Attributes

*   `firebaseLinks` (*type:* `list(GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaFirebaseLink.t)`, *default:* `nil`) - List of FirebaseLinks. This will have at most one value.
*   `nextPageToken` (*type:* `String.t`, *default:* `nil`) - A token, which can be sent as `page_token` to retrieve the next page. If this field is omitted, there are no subsequent pages. Currently, Google Analytics supports only one FirebaseLink per property, so this will never be populated.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.