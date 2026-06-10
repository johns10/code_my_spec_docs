# Recase

Recase allows you to convert string from any to any case.

This module contains public interface.

## to_pascal/1

Converts string or atom to PascalCase (aka UpperCase).

## Examples

    iex> Recase.to_pascal("some-value")
    "SomeValue"

    iex> Recase.to_pascal("some value")
    "SomeValue"

    iex> Recase.to_pascal(:someValue)
    :SomeValue

## to_camel/1

Converts string or atom to camelCase.

## Examples

    iex> Recase.to_camel("some-value")
    "someValue"

    iex> Recase.to_camel("Some Value")
    "someValue"

    iex> Recase.to_camel(:some_value)
    :someValue

## to_snake/1

Converts string or atom to snake_case.

## Examples

    iex> Recase.to_snake("some-value")
    "some_value"

    iex> Recase.to_snake("someValue")
    "some_value"

    iex> Recase.to_snake(:someValue)
    :some_value

## to_kebab/1

Converts string to kebab-case.

## Examples

    iex> Recase.to_kebab("SomeValue")
    "some-value"

    iex> Recase.to_kebab("some value")
    "some-value"

## to_constant/1

Converts string or atom to CONSTANT_CASE.

## Examples

    iex> Recase.to_constant("SomeValue")
    "SOME_VALUE"

    iex> Recase.to_constant("some value")
    "SOME_VALUE"

    iex> Recase.to_constant(:someValue)
    :SOME_VALUE

## to_dot/1

Converts string to dot.case

## Examples

    iex> Recase.to_dot("SomeValue")
    "some.value"

    iex> Recase.to_dot("some value")
    "some.value"

## to_sentence/1

Converts string to Sentence case

## Examples

    iex> Recase.to_sentence("SomeValue")
    "Some value"

    iex> Recase.to_sentence("some value")
    "Some value"

## to_title/1

Converts string to Title Case

## Examples

    iex> Recase.to_title("SomeValue")
    "Some Value"

    iex> Recase.to_title("some value")
    "Some Value"

## to_header/1

Converts string to Header-Case

## Examples

    iex> Recase.to_header("SomeValue")
    "Some-Value"

    iex> Recase.to_header("some value")
    "Some-Value"

## to_name/1

Converts string to Name Case

## Examples

    iex> Recase.to_name("mccarthy o'donnell")
    "McCarthy O'Donnell"

    iex> Recase.to_name("von streit")
    "von Streit"