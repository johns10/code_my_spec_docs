# Git.URLParser

## Purpose

Parses HTTPS git repository URLs to extract provider information (github.com, gitlab.com, etc.) and construct authenticated URLs with injected access tokens for git operations.

## Public API

```elixir
# Provider Detection
@spec provider(url :: String.t()) :: {:ok, atom()} | {:error, :invalid_url | :unsupported_provider}

# URL Construction
@spec inject_token(url :: String.t(), token :: String.t()) :: {:ok, String.t()} | {:error, :invalid_url}
```

## Execution Flow

### Determine Provider
1. **URL Validation**: Verify URL is HTTPS format (`https://...`)
2. **Host Extraction**: Extract host from URL (e.g., `github.com` from `https://github.com/owner/repo.git`)
3. **Provider Mapping**: Map host to provider atom:
   - `github.com` → `:github`
   - `gitlab.com` → `:gitlab`
   - Unknown hosts → return `{:error, :unsupported_provider}`
4. **Result Return**: Return provider atom or error

### Inject Token
1. **URL Validation**: Verify URL is valid HTTPS format
2. **Host Extraction**: Extract host from URL
3. **Token Injection**: Construct authenticated URL:
   - Transform `https://github.com/owner/repo.git` to `https://TOKEN@github.com/owner/repo.git`
4. **Result Return**: Return authenticated URL string or error

## Implementation Notes

### Supported Providers
- `:github` - github.com
- `:gitlab` - gitlab.com
- Extensible to other providers as needed

### URL Format Example
```elixir
# Input:
"https://github.com/owner/repo.git"

# Output after inject_token with "ghp_token123":
"https://ghp_token123@github.com/owner/repo.git"
```

### Error Cases
- Non-HTTPS URLs (e.g., SSH format)
- Malformed URLs
- URLs with unknown or unsupported hosts
- Empty or nil inputs
