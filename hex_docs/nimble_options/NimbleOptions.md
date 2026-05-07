# NimbleOptions

Provides a standard API to handle keyword-list-based options.

`NimbleOptions` allows developers to create schemas using a
pre-defined set of options and types. The main benefits are:

  * A single unified way to define simple static options
  * Config validation against schemas
  * Automatic doc generation

## Schema Options

These are the options supported in a *schema*. They are what
defines the validation for the items in the given schema.

* `:type` - The type of the option item. The default value is `:any`.

* `:required` (`t:boolean/0`) - Defines if the option item is required. The default value is `false`.

* `:default` (`t:term/0`) - The default value for the option item if that option is not specified. This value
  is *validated* according to the given `:type`. This means that you cannot
  have, for example, `type: :integer` and use `default: "a string"`.

* `:keys` (`t:keyword/0`) - Available for types `:keyword_list`, `:non_empty_keyword_list`, and `:map`,
  it defines which set of keys are accepted for the option item. The value of the
  `:keys` option is a schema itself. For example: `keys: [foo: [type: :atom]]`.
  Use `:*` as the key to allow multiple arbitrary keys and specify their schema:
  `keys: [*: [type: :integer]]`.

* `:deprecated` (`t:String.t/0`) - Defines a message to indicate that the option item is deprecated. The message will be displayed as a warning when passing the item.

* `:doc` (`t:String.t/0` or `false`) - The documentation for the option item.

* `:subsection` (`t:String.t/0`) - The title of separate subsection of the options' documentation

* `:type_doc` (`t:String.t/0` or `false`) - The type doc to use *in the documentation* for the option item. If `false`,
  no type documentation is added to the item. If it's a string, it can be
  anything. For example, you can use `"a list of PIDs"`, or you can use
  a typespec reference that ExDoc can link to the type definition, such as
  `` "`t:binary/0`" ``. You can use Markdown in this documentation. If the
  `:type_doc` option is not present, NimbleOptions tries to produce a type
  documentation automatically if it can do it unambiguously. For example,
  if `type: :integer`, NimbleOptions will use `t:integer/0` as the
  auto-generated type doc.

* `:type_spec` (`t:Macro.t/0`) - The quoted spec to use *in the typespec* for the option item. You should use this
  when the auto-generated spec is not specific enough. For example, if you are performing
  custom validation on an option (with the `{:custom, ...}` type), then the
  generated type spec for that option will always be `t:term/0`, but you can use
  this option to customize that. The value for this option **must** be a quoted Elixir
  term. For example, if you have an `:exception` option that is validated with a
  `{:custom, ...}` type (based on `is_exception/1`), you can override the type
  spec for that option to be `quote(do: Exception.t())`. *Available since v1.1.0*.



## Types

  * `:any` - Any type.

  * `:keyword_list` - A keyword list.

  * `:non_empty_keyword_list` - A non-empty keyword list.

  * `:map` - A map consisting of `:atom` keys. Shorthand for `{:map, :atom, :any}`.
    Keys can be specified using the `keys` option.

  * `{:map, key_type, value_type}` - A map consisting of `key_type` keys and
    `value_type` values.

  * `:atom` - An atom.

  * `:string` - A string.

  * `:boolean` - A boolean.

  * `:integer` - An integer.

  * `:non_neg_integer` - A non-negative integer.

  * `:pos_integer` - A positive integer.

  * `:float` - A float.

  * `:timeout` - A non-negative integer or the atom `:infinity`.

  * `:pid` - A PID (process identifier).

  * `:reference` - A reference (see `t:reference/0`).

  * `nil` - The value `nil` itself. Available since v1.0.0.

  * `:mfa` - A named function in the format `{module, function, arity}` where
    `arity` is a list of arguments. For example, `{MyModule, :my_fun, [arg1, arg2]}`.

  * `:mod_arg` - A module along with arguments, such as `{MyModule, arguments}`.
    Usually used for process initialization using `start_link` and similar. The
    second element of the tuple can be any term.

  * `{:fun, arity}` - Any function with the specified arity.

  * `{:in, choices}` - A value that is a member of one of the `choices`. `choices`
    should be a list of terms or a `Range`. The value is an element in said
    list of terms, that is, `value in choices` is `true`. This was previously
    called `:one_of` and the `:in` name is available since version 0.3.3 (`:one_of`
    has been removed in v0.4.0).

  * `{:custom, mod, fun, args}` - A custom type. The related value must be validated
    by `mod.fun(values, ...args)`. The function should return `{:ok, value}` or
    `{:error, message}`.

  * `{:or, subtypes}` - A value that matches one of the given `subtypes`. The value is
    matched against the subtypes in the order specified in the list of `subtypes`. If
    one of the subtypes matches and **updates** (casts) the given value, the updated
    value is used. For example: `{:or, [:string, :boolean, {:fun, 2}]}`. If one of the
    subtypes is a keyword list or map, you won't be able to pass `:keys` directly. For this reason,
    `:keyword_list`, `:non_empty_keyword_list`, and `:map` are special cased and can
    be used as subtypes with `{:keyword_list, keys}`, `{:non_empty_keyword_list, keys}` or `{:map, keys}`.
    For example, a type such as `{:or, [:boolean, keyword_list: [enabled: [type: :boolean]]]}`
    would match either a boolean or a keyword list with the `:enabled` boolean option in it.

  * `{:list, subtype}` - A list where all elements match `subtype`. `subtype` can be any
    of the accepted types listed here. Empty lists are allowed. The resulting validated list
    contains the validated (and possibly updated) elements, each as returned after validation
    through `subtype`. For example, if `subtype` is a custom validator function that returns
    an updated value, then that updated value is used in the resulting list. Validation
    fails at the *first* element that is invalid according to `subtype`. If `subtype` is
    a keyword list or map, you won't be able to pass `:keys` directly. For this reason,
    `:keyword_list`, `:non_empty_keyword_list`, and `:map` are special cased and can
    be used as the subtype by using `{:keyword_list, keys}`, `{:non_empty_keyword_list, keys}`
    or `{:keyword_list, keys}`. For example, a type such as
    `{:list, {:keyword_list, enabled: [type: :boolean]}}` would a *list of keyword lists*,
    where each keyword list in the list could have the `:enabled` boolean option in it.

  * `{:tuple, list_of_subtypes}` - A tuple as described by `tuple_of_subtypes`.
    `list_of_subtypes` must be a list with the same length as the expected tuple.
    Each of the list's elements must be a subtype that should match the given element in that
    same position. For example, to describe 3-element tuples with an atom, a string, and
    a list of integers you would use the type `{:tuple, [:atom, :string, {:list, :integer}]}`.
    *Available since v0.4.1*.

  * `{:struct, struct_name}` - An instance of the struct type given.

## Example

    iex> schema = [
    ...>   producer: [
    ...>     type: :non_empty_keyword_list,
    ...>     required: true,
    ...>     keys: [
    ...>       module: [required: true, type: :mod_arg],
    ...>       concurrency: [
    ...>         type: :pos_integer,
    ...>       ]
    ...>     ]
    ...>   ]
    ...> ]
    ...>
    ...> config = [
    ...>   producer: [
    ...>     concurrency: 1,
    ...>   ]
    ...> ]
    ...>
    ...> {:error, %NimbleOptions.ValidationError{} = error} = NimbleOptions.validate(config, schema)
    ...> Exception.message(error)
    "required :module option not found, received options: [:concurrency] (in options [:producer])"

## Nested Option Items

`NimbleOptions` allows option items to be nested so you can recursively validate
any item down the options tree.

### Example

    iex> schema = [
    ...>   producer: [
    ...>     required: true,
    ...>     type: :non_empty_keyword_list,
    ...>     keys: [
    ...>       rate_limiting: [
    ...>         type: :non_empty_keyword_list,
    ...>         keys: [
    ...>           interval: [required: true, type: :pos_integer]
    ...>         ]
    ...>       ]
    ...>     ]
    ...>   ]
    ...> ]
    ...>
    ...> config = [
    ...>   producer: [
    ...>     rate_limiting: [
    ...>       interval: :oops!
    ...>     ]
    ...>   ]
    ...> ]
    ...>
    ...> {:error, %NimbleOptions.ValidationError{} = error} = NimbleOptions.validate(config, schema)
    ...> Exception.message(error)
    "invalid value for :interval option: expected positive integer, got: :oops! (in options [:producer, :rate_limiting])"

## Validating Schemas

Each time `validate/2` is called, the given schema itself will be validated before validating
the options.

In most applications the schema will never change but validating options will be done
repeatedly.

To avoid the extra cost of validating the schema, it is possible to validate the schema once,
and then use that valid schema directly. This is done by using the `new!/1` function first, and
then passing the returned schema to `validate/2`.

> #### Create the Schema at Compile Time {: .tip}
>
> If your option schema doesn't include any runtime-only terms in it (such as anonymous
> functions), you can call `new!/1` to validate the schema and returned a *compiled* schema
> **at compile time**. This is an efficient way to avoid doing any unnecessary work at
> runtime. See the example below for more information.

### Example

    iex> raw_schema = [
    ...>   hostname: [
    ...>     required: true,
    ...>     type: :string
    ...>   ]
    ...> ]
    ...>
    ...> schema = NimbleOptions.new!(raw_schema)
    ...> NimbleOptions.validate([hostname: "elixir-lang.org"], schema)
    {:ok, hostname: "elixir-lang.org"}

Calling `new!/1` from a function that receives options will still validate the schema each time
that function is called. Declaring the schema as a module attribute is supported:

    @options_schema NimbleOptions.new!([...])

This schema will be validated at compile time. Calling `docs/1` on that schema is also
supported.

## docs(schema, options \\ [])

Returns documentation for the given schema.

You can use this to inject documentation in your docstrings. For example,
say you have your schema in a module attribute:

    @options_schema [...]

With this, you can use `docs/1` to inject documentation:

    @doc "Supported options:\n#{NimbleOptions.docs(@options_schema)}"

## Options

  * `:nest_level` - an integer deciding the "nest level" of the generated
    docs. This is useful when, for example, you use `docs/2` inside the `:doc`
    option of another schema. For example, if you have the following nested schema:

        nested_schema = [
          allowed_messages: [type: :pos_integer, doc: "Allowed messages."],
          interval: [type: :pos_integer, doc: "Interval."]
        ]

    then you can document it inside another schema with its nesting level increased:

        schema = [
          producer: [
            type: {:or, [:string, keyword_list: nested_schema]},
            doc:
              "Either a string or a keyword list with the following keys:\n\n" <>
                NimbleOptions.docs(nested_schema, nest_level: 1)
          ],
          other_key: [type: :string]
        ]

## new!(schema)

Validates the given `schema` and returns a wrapped schema to be used with `validate/2`.

If the given schema is not valid, raises a `NimbleOptions.ValidationError`.

## option_typespec(schema)

Returns the quoted typespec for any option described by the given schema.

The returned quoted code represents the **type union** for all possible
keys in the schema, alongside their type. Nested keyword lists are
spec'ed as `t:keyword/0`.

## Usage

Because of how typespecs are treated by the Elixir compiler, you have
to use `unquote/1` on the return value of this function to use it
in a typespec:

    @type option() :: unquote(NimbleOptions.option_typespec(my_schema))

This function returns the type union for a single option: to give you
flexibility to combine it and use it in your own typespecs. For example,
if you only validate part of the options through NimbleOptions, you could
write a spec like this:

    @type my_option() ::
            {:my_opt1, integer()}
            | {:my_opt2, boolean()}
            | unquote(NimbleOptions.option_typespec(my_schema))

If you want to spec a whole schema, you could write something like this:

    @type options() :: [unquote(NimbleOptions.option_typespec(my_schema))]

## Example

    schema = [
      int: [type: :integer],
      number: [type: {:or, [:integer, :float]}]
    ]

    @type option() :: unquote(NimbleOptions.option_typespec(schema))

The code above would essentially compile to:

    @type option() :: {:int, integer()} | {:number, integer() | float()}

## validate(options, schema)

Validates the given `options` with the given `schema`.

See the module documentation for what a `schema` is.

If the validation is successful, this function returns `{:ok, validated_options}`
where `validated_options` is a keyword list. If the validation fails, this
function returns `{:error, validation_error}` where `validation_error` is a
`NimbleOptions.ValidationError` struct explaining what's wrong with the options.
You can use `raise/1` with that struct or `Exception.message/1` to turn it into a string.

## validate!(options, schema)

Validates the given `options` with the given `schema` and raises if they're not valid.

This function behaves exactly like `validate/2`, but returns the options directly
if they're valid or raises a `NimbleOptions.ValidationError` exception otherwise.

## schema/0

A schema.

See the module documentation for more information.

## t/0

The `NimbleOptions` struct embedding a validated schema.

See the [*Validating Schemas* section](#module-validating-schemas) in
the module documentation.