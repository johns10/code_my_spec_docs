# Phoenix.HTML.FormData

Converts a data structure into a `Phoenix.HTML.Form` struct.

## Ecto integration

Phoenix provides integration of forms with Ecto changesets and data
structures via the [phoenix_ecto](https://hex.pm/packages/phoenix_ecto) package.
If a project was generated without Ecto support that dependency will need to be
manually added.

## input_validations(data, form, field)

Returns the HTML5 validations that would apply to
the given field.

## input_value(data, form, field)

Returns the value for the given field.

## to_form(data, options)

Converts a data structure into a [`Phoenix.HTML.Form`](`t:Phoenix.HTML.Form.t/0`) struct.

The options have their meaning defined by the underlying
implementation but all shared options below are expected to
be implemented. All remaining options must be stored in the
returned struct.

## Shared options

  * `:as` - the value to be used as the form name

  * `:id` - the ID of the form attribute. All form inputs will
    be prefixed by the given ID

## to_form(data, form, field, options)

Converts the field in the given form based on the data structure
into a list of [`Phoenix.HTML.Form`](`t:Phoenix.HTML.Form.t/0`) structs.

The options have their meaning defined by the underlying
implementation but all shared options below are expected to
be implemented. All remaining options must be stored in the
returned struct.

## Shared Options

  * `:id` - the id to be used in the form, defaults to the
    concatenation of the given `field` to the parent form id

  * `:as` - the name to be used in the form, defaults to the
    concatenation of the given `field` to the parent form name

  * `:default` - the value to use if none is available

  * `:prepend` - the values to prepend when rendering. This only
    applies if the field value is a list and no parameters were
    sent through the form.

  * `:append` - the values to append when rendering. This only
    applies if the field value is a list and no parameters were
    sent through the form.

  * `:action` - The user defined action being taken by the form, such
    as `:validate`, `:save`, etc.

## input_validations/3

Returns the HTML5 validations that would apply to
the given field.

## input_value/3

Returns the value for the given field.

## to_form/2

Converts a data structure into a [`Phoenix.HTML.Form`](`t:Phoenix.HTML.Form.t/0`) struct.

The options have their meaning defined by the underlying
implementation but all shared options below are expected to
be implemented. All remaining options must be stored in the
returned struct.

## Shared options

  * `:as` - the value to be used as the form name

  * `:id` - the ID of the form attribute. All form inputs will
    be prefixed by the given ID

## to_form/4

Converts the field in the given form based on the data structure
into a list of [`Phoenix.HTML.Form`](`t:Phoenix.HTML.Form.t/0`) structs.

The options have their meaning defined by the underlying
implementation but all shared options below are expected to
be implemented. All remaining options must be stored in the
returned struct.

## Shared Options

  * `:id` - the id to be used in the form, defaults to the
    concatenation of the given `field` to the parent form id

  * `:as` - the name to be used in the form, defaults to the
    concatenation of the given `field` to the parent form name

  * `:default` - the value to use if none is available

  * `:prepend` - the values to prepend when rendering. This only
    applies if the field value is a list and no parameters were
    sent through the form.

  * `:append` - the values to append when rendering. This only
    applies if the field value is a list and no parameters were
    sent through the form.

  * `:action` - The user defined action being taken by the form, such
    as `:validate`, `:save`, etc.

## t/0

All the types that implement this protocol.