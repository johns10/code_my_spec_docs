# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaFirebaseLink

A link between a Google Analytics property and a Firebase project.

## Attributes

*   `createTime` (*type:* `DateTime.t`, *default:* `nil`) - Output only. Time when this FirebaseLink was originally created.
*   `name` (*type:* `String.t`, *default:* `nil`) - Output only. Example format: properties/1234/firebaseLinks/5678
*   `project` (*type:* `String.t`, *default:* `nil`) - Immutable. Firebase project resource name. When creating a FirebaseLink, you may provide this resource name using either a project number or project ID. Once this resource has been created, returned FirebaseLinks will always have a project_name that contains a project number. Format: 'projects/{project number}' Example: 'projects/1234'

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.