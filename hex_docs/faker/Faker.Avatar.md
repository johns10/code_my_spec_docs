# Faker.Avatar

Functions for generate random urls for avatars.

## image_url()

Return avatar url with random set and background.

## Examples

    iex> Faker.Avatar.image_url()
    "https://robohash.org/set_set1/bgset_bg2/kQqaIfGqxsjFoNIT"
    iex> Faker.Avatar.image_url()
    "https://robohash.org/set_set2/bgset_bg2/6"
    iex> Faker.Avatar.image_url()
    "https://robohash.org/set_set2/bgset_bg2/J"
    iex> Faker.Avatar.image_url()
    "https://robohash.org/set_set3/bgset_bg1/JNth88PrhGDhwp4LNQMt"

## image_url(slug)

Return avatar url for given `slug`.

## Examples

    iex> Faker.Avatar.image_url('faker')
    "https://robohash.org/faker"
    iex> Faker.Avatar.image_url('elixir')
    "https://robohash.org/elixir"
    iex> Faker.Avatar.image_url('plug')
    "https://robohash.org/plug"
    iex> Faker.Avatar.image_url('ecto')
    "https://robohash.org/ecto"

## image_url(width, height)

Return avatar url with random set and background, with size `width` x `height`
pixels.

## Examples

    iex> Faker.Avatar.image_url(200, 200)
    "https://robohash.org/set_set2/bgset_bg2/ppkQqaIfGqx?size=200x200"
    iex> Faker.Avatar.image_url(800, 600)
    "https://robohash.org/set_set2/bgset_bg2/oNITNnu6?size=800x600"
    iex> Faker.Avatar.image_url(32, 32)
    "https://robohash.org/set_set3/bgset_bg1/J?size=32x32"
    iex> Faker.Avatar.image_url(128, 128)
    "https://robohash.org/set_set1/bgset_bg2/JNth88PrhGDhwp4LNQMt?size=128x128"

## image_url(slug, width, height)

Return avatar url for given `slug`, with size `width` x `height` pixels.

## Examples

    iex> Faker.Avatar.image_url('phoenix', 100, 100)
    "https://robohash.org/phoenix?size=100x100"
    iex> Faker.Avatar.image_url('haskell', 200, 200)
    "https://robohash.org/haskell?size=200x200"
    iex> Faker.Avatar.image_url('ocaml', 300, 300)
    "https://robohash.org/ocaml?size=300x300"
    iex> Faker.Avatar.image_url('idris', 400, 400)
    "https://robohash.org/idris?size=400x400"