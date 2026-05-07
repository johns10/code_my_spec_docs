# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaCustomDimension

A definition for a CustomDimension.

## Attributes

*   `description` (*type:* `String.t`, *default:* `nil`) - Optional. Description for this custom dimension. Max length of 150 characters.
*   `disallowAdsPersonalization` (*type:* `boolean()`, *default:* `nil`) - Optional. If set to true, sets this dimension as NPA and excludes it from ads personalization. This is currently only supported by user-scoped custom dimensions.
*   `displayName` (*type:* `String.t`, *default:* `nil`) - Required. Display name for this custom dimension as shown in the Analytics UI. Max length of 82 characters, alphanumeric plus space and underscore starting with a letter. Legacy system-generated display names may contain square brackets, but updates to this field will never permit square brackets.
*   `name` (*type:* `String.t`, *default:* `nil`) - Output only. Resource name for this CustomDimension resource. Format: properties/{property}/customDimensions/{customDimension}
*   `parameterName` (*type:* `String.t`, *default:* `nil`) - Required. Immutable. Tagging parameter name for this custom dimension. If this is a user-scoped dimension, then this is the user property name. If this is an event-scoped dimension, then this is the event parameter name. If this is an item-scoped dimension, then this is the parameter name found in the eCommerce items array. May only contain alphanumeric and underscore characters, starting with a letter. Max length of 24 characters for user-scoped dimensions, 40 characters for event-scoped dimensions.
*   `scope` (*type:* `String.t`, *default:* `nil`) - Required. Immutable. The scope of this dimension.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.