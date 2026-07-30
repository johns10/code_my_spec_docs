# CodeMySpecWeb.TokenController

Exchanges a deployed environment's refresh secret for a short-lived access token. The refresh secret can do nothing else, and the five authenticated surfaces accept only the short-lived tokens — so a credential captured from any of them is useless within minutes. Refusals distinguish expiry from a bad credential so the app knows to renew and retry, and a live widget socket re-authenticates in place rather than dropping.

## Type

controller
