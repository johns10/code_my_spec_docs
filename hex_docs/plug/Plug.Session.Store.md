# Plug.Session.Store

Specification for session stores.

## get(store)

Gets the store name from an atom or a module.

    iex> Plug.Session.Store.get(CustomStore)
    CustomStore

    iex> Plug.Session.Store.get(:cookie)
    Plug.Session.COOKIE

## delete/3

Removes the session associated with given session id from the store.

## get/3

Parses the given cookie.

Returns a session id and the session contents. The session id is any
value that can be used to identify the session by the store.

The session id may be nil in case the cookie does not identify any
value in the store. The session contents must be a map.

## init/1

Initializes the store.

The options returned from this function will be given
to `c:get/3`, `c:put/4` and `c:delete/3`.

## put/4

Stores the session associated with given session id.

If `nil` is given as id, a new session id should be
generated and returned.

## sid/0

The internal reference to the session in the store.

## cookie/0

The cookie value that will be sent in cookie headers. This value should be
base64 encoded to avoid security issues.

## session/0

The session contents, the final data to be stored after it has been built
with `Plug.Conn.put_session/3` and the other session manipulating functions.