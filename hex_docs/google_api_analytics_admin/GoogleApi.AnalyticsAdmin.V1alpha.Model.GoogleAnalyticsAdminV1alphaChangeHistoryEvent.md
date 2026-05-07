# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaChangeHistoryEvent

A set of changes within a Google Analytics account or its child properties that resulted from the same cause. Common causes would be updates made in the Google Analytics UI, changes from customer support, or automatic Google Analytics system changes.

## Attributes

*   `actorType` (*type:* `String.t`, *default:* `nil`) - The type of actor that made this change.
*   `changeTime` (*type:* `DateTime.t`, *default:* `nil`) - Time when change was made.
*   `changes` (*type:* `list(GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaChangeHistoryChange.t)`, *default:* `nil`) - A list of changes made in this change history event that fit the filters specified in SearchChangeHistoryEventsRequest.
*   `changesFiltered` (*type:* `boolean()`, *default:* `nil`) - If true, then the list of changes returned was filtered, and does not represent all changes that occurred in this event.
*   `id` (*type:* `String.t`, *default:* `nil`) - ID of this change history event. This ID is unique across Google Analytics.
*   `userActorEmail` (*type:* `String.t`, *default:* `nil`) - Email address of the Google account that made the change. This will be a valid email address if the actor field is set to USER, and empty otherwise. Google accounts that have been deleted will cause an error.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.