# Faker.App

Functions for generating app specific properties.

## author()

Returns an author name.

## Examples

    iex> Faker.App.author()
    "Mr. Ozella Sipes"
    iex> Faker.App.author()
    "Aniya Schiller"
    iex> Faker.App.author()
    "Frederique Murphy"
    iex> Faker.App.author()
    "Rutherford Inc"

## name()

Returns an app name.

## Examples

    iex> Faker.App.name()
    "Redhold"
    iex> Faker.App.name()
    "Tempsoft"
    iex> Faker.App.name()
    "Tempsoft"
    iex> Faker.App.name()
    "Quo Lux"

## semver(opts \\ [])

Returns a SemVer version.

## Options:

* `:allow_pre` - when `true`, a pre-release identifier (e.g.: `-dev`)
  will be appended (default: `false`)
* `:allow_build` - when `true`, a build identifier (e.g.: `+001`)
  will be appended (default: `false`)

## Examples

    iex> Faker.App.semver()
    "5.42.64"
    iex> Faker.App.semver()
    "0.2.8"
    iex> Faker.App.semver()
    "7.0.5"
    iex> Faker.App.semver()
    "5.7.0"

## version()

Returns a version number.

## Examples

    iex> Faker.App.version()
    "0.1.5"
    iex> Faker.App.version()
    "2.6.4"
    iex> Faker.App.version()
    "0.10"
    iex> Faker.App.version()
    "3.2"