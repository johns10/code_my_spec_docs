# UUID

UUID generator and utilities for [Elixir](http://elixir-lang.org/).
See [RFC 4122](http://www.ietf.org/rfc/rfc4122.txt).

## binary_to_string!(uuid, format \\ :default)

Convert binary UUID data to a string.

Will raise an ArgumentError if the given binary is not valid UUID data, or
the format argument is not one of: `:default`, `:hex`, or `:urn`.

## Examples

```elixir
iex> UUID.binary_to_string!(<<135, 13, 248, 232, 49, 7, 68, 135,
...>        131, 22, 129, 224, 137, 184, 194, 207>>)
"870df8e8-3107-4487-8316-81e089b8c2cf"

iex> UUID.binary_to_string!(<<142, 161, 81, 61, 248, 161, 77, 234, 155,
...>        234, 107, 143, 75, 91, 110, 115>>, :hex)
"8ea1513df8a14dea9bea6b8f4b5b6e73"

iex> UUID.binary_to_string!(<<239, 27, 26, 40, 238, 52, 17, 227, 136,
...>        19, 20, 16, 159, 241, 163, 4>>, :urn)
"urn:uuid:ef1b1a28-ee34-11e3-8813-14109ff1a304"

```

## info(uuid)

Inspect a UUID and return tuple with `{:ok, result}`, where result is
information about its 128-bit binary content, type,
version and variant.

Timestamp portion is not checked to see if it's in the future, and therefore
not yet assignable. See "Validation mechanism" in section 3 of
[RFC 4122](http://www.ietf.org/rfc/rfc4122.txt).

Will return `{:error, message}` if the given string is not a UUID representation
in a format like:
* `"870df8e8-3107-4487-8316-81e089b8c2cf"`
* `"8ea1513df8a14dea9bea6b8f4b5b6e73"`
* `"urn:uuid:ef1b1a28-ee34-11e3-8813-14109ff1a304"`

## Examples

```elixir
iex> UUID.info("870df8e8-3107-4487-8316-81e089b8c2cf")
{:ok, [uuid: "870df8e8-3107-4487-8316-81e089b8c2cf",
 binary: <<135, 13, 248, 232, 49, 7, 68, 135, 131, 22, 129, 224, 137, 184, 194, 207>>,
 type: :default,
 version: 4,
 variant: :rfc4122]}

iex> UUID.info("8ea1513df8a14dea9bea6b8f4b5b6e73")
{:ok, [uuid: "8ea1513df8a14dea9bea6b8f4b5b6e73",
 binary: <<142, 161, 81, 61, 248, 161, 77, 234, 155,
            234, 107, 143, 75, 91, 110, 115>>,
 type: :hex,
 version: 4,
 variant: :rfc4122]}

iex> UUID.info("urn:uuid:ef1b1a28-ee34-11e3-8813-14109ff1a304")
{:ok, [uuid: "urn:uuid:ef1b1a28-ee34-11e3-8813-14109ff1a304",
 binary: <<239, 27, 26, 40, 238, 52, 17, 227, 136, 19, 20, 16, 159, 241, 163, 4>>,
 type: :urn,
 version: 1,
 variant: :rfc4122]}

iex> UUID.info("12345")
{:error, "Invalid argument; Not a valid UUID: 12345"}

```

## info!(uuid_string)

Inspect a UUID and return information about its 128-bit binary content, type,
version and variant.

Timestamp portion is not checked to see if it's in the future, and therefore
not yet assignable. See "Validation mechanism" in section 3 of
[RFC 4122](http://www.ietf.org/rfc/rfc4122.txt).

Will raise an `ArgumentError` if the given string is not a UUID representation
in a format like:
* `"870df8e8-3107-4487-8316-81e089b8c2cf"`
* `"8ea1513df8a14dea9bea6b8f4b5b6e73"`
* `"urn:uuid:ef1b1a28-ee34-11e3-8813-14109ff1a304"`

## Examples

```elixir
iex> UUID.info!("870df8e8-3107-4487-8316-81e089b8c2cf")
[uuid: "870df8e8-3107-4487-8316-81e089b8c2cf",
 binary: <<135, 13, 248, 232, 49, 7, 68, 135, 131, 22, 129, 224, 137, 184, 194, 207>>,
 type: :default,
 version: 4,
 variant: :rfc4122]

iex> UUID.info!("8ea1513df8a14dea9bea6b8f4b5b6e73")
[uuid: "8ea1513df8a14dea9bea6b8f4b5b6e73",
 binary: <<142, 161, 81, 61, 248, 161, 77, 234, 155,
            234, 107, 143, 75, 91, 110, 115>>,
 type: :hex,
 version: 4,
 variant: :rfc4122]

iex> UUID.info!("urn:uuid:ef1b1a28-ee34-11e3-8813-14109ff1a304")
[uuid: "urn:uuid:ef1b1a28-ee34-11e3-8813-14109ff1a304",
 binary: <<239, 27, 26, 40, 238, 52, 17, 227, 136, 19, 20, 16, 159, 241, 163, 4>>,
 type: :urn,
 version: 1,
 variant: :rfc4122]

```

## string_to_binary!(arg1)

Convert a UUID string to its binary data equivalent.

Will raise an ArgumentError if the given string is not a UUID representation
in a format like:
* `"870df8e8-3107-4487-8316-81e089b8c2cf"`
* `"8ea1513df8a14dea9bea6b8f4b5b6e73"`
* `"urn:uuid:ef1b1a28-ee34-11e3-8813-14109ff1a304"`

## Examples

```elixir
iex> UUID.string_to_binary!("870df8e8-3107-4487-8316-81e089b8c2cf")
<<135, 13, 248, 232, 49, 7, 68, 135, 131, 22, 129, 224, 137, 184, 194, 207>>

iex> UUID.string_to_binary!("8ea1513df8a14dea9bea6b8f4b5b6e73")
<<142, 161, 81, 61, 248, 161, 77, 234, 155, 234, 107, 143, 75, 91, 110, 115>>

iex> UUID.string_to_binary!("urn:uuid:ef1b1a28-ee34-11e3-8813-14109ff1a304")
<<239, 27, 26, 40, 238, 52, 17, 227, 136, 19, 20, 16, 159, 241, 163, 4>>

```

## uuid1(format \\ :default)

Generate a new UUID v1. This version uses a combination of one or more of:
unix epoch, random bytes, pid hash, and hardware address.

## Examples

```elixir
iex> UUID.uuid1()
"cdfdaf44-ee35-11e3-846b-14109ff1a304"

iex> UUID.uuid1(:default)
"cdfdaf44-ee35-11e3-846b-14109ff1a304"

iex> UUID.uuid1(:hex)
"cdfdaf44ee3511e3846b14109ff1a304"

iex> UUID.uuid1(:urn)
"urn:uuid:cdfdaf44-ee35-11e3-846b-14109ff1a304"

```

## uuid1(clock_seq, node, format \\ :default)

Generate a new UUID v1, with an existing clock sequence and node address. This
version uses a combination of one or more of: unix epoch, random bytes,
pid hash, and hardware address.

## Examples

```elixir
iex> UUID.uuid1()
"cdfdaf44-ee35-11e3-846b-14109ff1a304"

iex> UUID.uuid1(:default)
"cdfdaf44-ee35-11e3-846b-14109ff1a304"

iex> UUID.uuid1(:hex)
"cdfdaf44ee3511e3846b14109ff1a304"

iex> UUID.uuid1(:urn)
"urn:uuid:cdfdaf44-ee35-11e3-846b-14109ff1a304"

```

## uuid3(namespace_or_uuid, name, format \\ :default)

Generate a new UUID v3. This version uses an MD5 hash of fixed value (chosen
based on a namespace atom - see Appendix C of
[RFC 4122](http://www.ietf.org/rfc/rfc4122.txt) and a name value. Can also be
given an existing UUID String instead of a namespace atom.

Accepted arguments are: `:dns`|`:url`|`:oid`|`:x500`|`:nil` OR uuid, String

## Examples

```elixir
iex> UUID.uuid3(:dns, "my.domain.com")
"03bf0706-b7e9-33b8-aee5-c6142a816478"

iex> UUID.uuid3(:dns, "my.domain.com", :default)
"03bf0706-b7e9-33b8-aee5-c6142a816478"

iex> UUID.uuid3(:dns, "my.domain.com", :hex)
"03bf0706b7e933b8aee5c6142a816478"

iex> UUID.uuid3(:dns, "my.domain.com", :urn)
"urn:uuid:03bf0706-b7e9-33b8-aee5-c6142a816478"

iex> UUID.uuid3("cdfdaf44-ee35-11e3-846b-14109ff1a304", "my.domain.com")
"8808f33a-3e11-3708-919e-15fba88908db"

```

## uuid4()

Generate a new UUID v4. This version uses pseudo-random bytes generated by
the `crypto` module.

## Examples

```elixir
iex> UUID.uuid4()
"fb49a0ec-d60c-4d20-9264-3b4cfe272106"

iex> UUID.uuid4(:default)
"fb49a0ec-d60c-4d20-9264-3b4cfe272106"

iex> UUID.uuid4(:hex)
"fb49a0ecd60c4d2092643b4cfe272106"

iex> UUID.uuid4(:urn)
"urn:uuid:fb49a0ec-d60c-4d20-9264-3b4cfe272106"
```

## uuid5(namespace_or_uuid, name, format \\ :default)

Generate a new UUID v5. This version uses an SHA1 hash of fixed value (chosen
based on a namespace atom - see Appendix C of
[RFC 4122](http://www.ietf.org/rfc/rfc4122.txt) and a name value. Can also be
given an existing UUID String instead of a namespace atom.

Accepted arguments are: `:dns`|`:url`|`:oid`|`:x500`|`:nil` OR uuid, String

## Examples

```elixir
iex> UUID.uuid5(:dns, "my.domain.com")
"016c25fd-70e0-56fe-9d1a-56e80fa20b82"

iex> UUID.uuid5(:dns, "my.domain.com", :default)
"016c25fd-70e0-56fe-9d1a-56e80fa20b82"

iex> UUID.uuid5(:dns, "my.domain.com", :hex)
"016c25fd70e056fe9d1a56e80fa20b82"

iex> UUID.uuid5(:dns, "my.domain.com", :urn)
"urn:uuid:016c25fd-70e0-56fe-9d1a-56e80fa20b82"

iex> UUID.uuid5("fb49a0ec-d60c-4d20-9264-3b4cfe272106", "my.domain.com")
"822cab19-df58-5eb4-98b5-c96c15c76d32"

```