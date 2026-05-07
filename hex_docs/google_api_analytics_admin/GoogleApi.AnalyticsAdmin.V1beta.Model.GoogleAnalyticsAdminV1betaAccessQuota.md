# GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaAccessQuota

Current state of all quotas for this Analytics property. If any quota for a property is exhausted, all requests to that property will return Resource Exhausted errors.

## Attributes

*   `concurrentRequests` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaAccessQuotaStatus.t`, *default:* `nil`) - Properties can use up to 50 concurrent requests.
*   `serverErrorsPerProjectPerHour` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaAccessQuotaStatus.t`, *default:* `nil`) - Properties and cloud project pairs can have up to 50 server errors per hour.
*   `tokensPerDay` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaAccessQuotaStatus.t`, *default:* `nil`) - Properties can use 250,000 tokens per day. Most requests consume fewer than 10 tokens.
*   `tokensPerHour` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaAccessQuotaStatus.t`, *default:* `nil`) - Properties can use 50,000 tokens per hour. An API request consumes a single number of tokens, and that number is deducted from all of the hourly, daily, and per project hourly quotas.
*   `tokensPerProjectPerHour` (*type:* `GoogleApi.AnalyticsAdmin.V1beta.Model.GoogleAnalyticsAdminV1betaAccessQuotaStatus.t`, *default:* `nil`) - Properties can use up to 25% of their tokens per project per hour. This amounts to Analytics 360 Properties can use 12,500 tokens per project per hour. An API request consumes a single number of tokens, and that number is deducted from all of the hourly, daily, and per project hourly quotas.

## decode(value, options)

Unwrap a decoded JSON object into its complex fields.