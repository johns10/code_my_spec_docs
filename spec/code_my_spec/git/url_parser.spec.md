# CodeMySpec.Git.URLParser

Parses HTTPS git repository URLs to extract provider information and construct authenticated URLs with injected access tokens. This module supports GitHub and GitLab providers, converting HTTPS URLs into authenticated formats suitable for git operations.

## Functions

### provider/1

Extracts the git provider type from an HTTPS repository URL by analyzing the host domain.

```elixir
@spec provider(url :: String.t() | nil) :: {:ok, :github | :gitlab} | {:error, :invalid_url | :unsupported_provider}
```

**Process**:
1. Guard against nil or empty string inputs, returning error immediately
2. Parse the URL using URI.parse to extract components
3. Validate that the URL uses HTTPS scheme and has a valid host
4. Normalize the host to lowercase for case-insensitive matching
5. Map the normalized host to a known provider atom (github.com or gitlab.com)
6. Return ok tuple with provider atom or error tuple for unsupported/invalid URLs

**Test Assertions**:
- identifies GitHub provider from standard HTTPS URL
- identifies GitHub provider from HTTPS URL without .git extension
- identifies GitHub provider from HTTPS URL with additional path segments
- identifies GitLab provider from standard HTTPS URL
- identifies GitLab provider from HTTPS URL without .git extension
- identifies GitLab provider from HTTPS URL with subgroups
- returns error for SSH URL format
- returns error for GitLab SSH URL format
- returns error for HTTP (non-HTTPS) URL
- returns error for malformed URL
- returns error for empty string
- returns error for nil input
- returns error for unknown git provider
- returns error for custom domain HTTPS URLs
- handles URLs with trailing slashes
- handles URLs with query parameters
- handles URLs with fragments
- handles URLs with mixed case domains
- handles URLs with www subdomain (returns unsupported_provider)
- handles very long repository paths
- handles URLs with port numbers
- handles whitespace in URL (returns invalid_url)
- is consistent with multiple calls on the same URL

### inject_token/2

Injects an access token into an HTTPS repository URL for authentication by adding it as userinfo in the URL structure.

```elixir
@spec inject_token(url :: String.t() | nil, token :: String.t() | nil) :: {:ok, String.t()} | {:error, :invalid_url}
```

**Process**:
1. Guard against nil or empty string URL inputs, returning error immediately
2. Parse the URL using URI.parse to validate HTTPS format
3. Construct a new URI struct with the token set as userinfo field
4. Convert the modified URI back to a string format
5. Return ok tuple with the authenticated URL string

**Test Assertions**:
- injects token into standard GitHub HTTPS URL
- injects token into GitHub URL without .git extension
- injects token into GitHub URL with additional path segments
- injects token into standard GitLab HTTPS URL
- injects token into GitLab URL without .git extension
- injects token into GitLab URL with subgroups
- returns error for SSH URL format
- returns error for HTTP (non-HTTPS) URL
- returns error for malformed URL
- returns error for empty URL
- returns error for nil URL
- handles empty token string (produces URL with empty userinfo)
- handles nil token (produces URL with no userinfo)
- handles token with special characters
- replaces existing credentials in URL
- replaces existing username in URL
- handles URL with trailing slash
- preserves query parameters
- preserves URL fragments
- handles very long tokens
- always produces a valid URL structure when given valid HTTPS URL
- is idempotent for the same inputs
- works with URLs from unsupported providers

## Dependencies

- URI