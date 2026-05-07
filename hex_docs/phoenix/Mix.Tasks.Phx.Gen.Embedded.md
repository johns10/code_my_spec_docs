# Mix.Tasks.Phx.Gen.Embedded

Generates an embedded Ecto schema for casting/validating data outside the DB.

```console
$ mix phx.gen.embedded Blog.Post title:string views:integer
```

The first argument is the schema module followed by the schema attributes.

The generated schema above will contain:

  * an embedded schema file in `lib/my_app/blog/post.ex`

## Attributes

The resource fields are given using `name:type` syntax
where type are the types supported by Ecto. Omitting
the type makes it default to `:string`:

```console
$ mix phx.gen.embedded Blog.Post title views:integer
```

The following types are supported:

  * `:integer`
  * `:float`
  * `:decimal`
  * `:boolean`
  * `:map`
  * `:string`
  * `:array`
  * `:references`
  * `:text`
  * `:date`
  * `:time`
  * `:time_usec`
  * `:naive_datetime`
  * `:naive_datetime_usec`
  * `:utc_datetime`
  * `:utc_datetime_usec`
  * `:uuid`
  * `:binary`
  * `:enum`

  * `:datetime` - An alias for `:naive_datetime`