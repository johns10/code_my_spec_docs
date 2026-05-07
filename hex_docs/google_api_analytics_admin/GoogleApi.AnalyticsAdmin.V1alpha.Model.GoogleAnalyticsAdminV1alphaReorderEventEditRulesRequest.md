# GoogleApi.AnalyticsAdmin.V1alpha.Model.GoogleAnalyticsAdminV1alphaReorderEventEditRulesRequest

Request message for ReorderEventEditRules RPC.

## Attributes

*   `eventEditRules` (*type:* `list(String.t)`, *default:* `nil`) - Required. EventEditRule resource names for the specified data stream, in the needed processing order. All EventEditRules for the stream must be present in the list.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.