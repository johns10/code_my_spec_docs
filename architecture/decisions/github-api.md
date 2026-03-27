# Use oapi_github for GitHub API integration

## Status
Accepted

## Context
The application integrates with GitHub for repository access, webhook handling, and code analysis. A typed client library reduces the surface area for API integration bugs.

## Options Considered
- **oapi_github** — Auto-generated typed client from GitHub's OpenAPI spec. Full API coverage with typed request/response structs.
- **Tentacat** — Community GitHub client. Good but manually maintained, can lag behind API changes.
- **Raw HTTP via Req** — Direct HTTP calls. Maximum flexibility but no type safety or API structure.

## Decision
Use oapi_github (`~> 0.3`) for GitHub API interactions. It provides typed structs for all GitHub API endpoints, generated directly from GitHub's OpenAPI specification, ensuring up-to-date coverage.

## Consequences
- Full GitHub API coverage with typed interfaces
- Auto-generated code can be verbose; wrap in application-level modules
- Authentication token management handled by application (via Assent OAuth flow)
