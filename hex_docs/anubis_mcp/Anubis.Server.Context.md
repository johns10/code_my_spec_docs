# Anubis.Server.Context

Read-only session and request context, set by the SDK before each callback.

The Session process builds a fresh Context before every user callback invocation.
Mutations have no lasting effect — the Session always overwrites it.

For STDIO transport, `headers` is empty and `remote_ip` is nil.
For HTTP transport, headers are normalized to lowercase string keys.