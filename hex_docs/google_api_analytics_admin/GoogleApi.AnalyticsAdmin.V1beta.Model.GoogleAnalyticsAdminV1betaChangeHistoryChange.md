# GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaChangeHistoryChange

A description of a change to a single Google Analytics resource.

## Attributes

*   `action` (*type:* `String.t`, *default:* `nil`) - The type of action that changed this resource.
*   `resource` (*type:* `String.t`, *default:* `nil`) - Resource name of the resource whose changes are described by this entry.
*   `resourceAfterChange` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaChangeHistoryChangeChangeHistoryResource.t`, *default:* `nil`) - Resource contents from after the change was made. If this resource was deleted in this change, this field will be missing.
*   `resourceBeforeChange` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaChangeHistoryChangeChangeHistoryResource.t`, *default:* `nil`) - Resource contents from before the change was made. If this resource was created in this change, this field will be missing.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.