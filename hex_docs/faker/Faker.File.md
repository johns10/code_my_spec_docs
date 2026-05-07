# Faker.File

Functions for generating file related data

## file_extension()

Returns a random file extension

## Examples

    iex> Faker.File.file_extension()
    "wav"
    iex> Faker.File.file_extension()
    "wav"
    iex> Faker.File.file_extension()
    "doc"
    iex> Faker.File.file_extension()
    "mov"

## file_extension(category)

Returns a random file extension from the category given
Available categories: :audio, :image, :text, :video, :office

## Examples

    iex> Faker.File.file_extension(:video)
    "mov"
    iex> Faker.File.file_extension(:image)
    "tiff"
    iex> Faker.File.file_extension(:audio)
    "flac"
    iex> Faker.File.file_extension(:office)
    "xls"

## file_name()

Returns a random file name

## Examples

    iex> Faker.File.file_name()
    "aliquam.jpg"
    iex> Faker.File.file_name()
    "deleniti.doc"
    iex> Faker.File.file_name()
    "qui.jpg"
    iex> Faker.File.file_name()
    "quibusdam.csv"

## file_name(category)

Returns a random file name from the category given
Available categories: :audio, :image, :text, :video, :office

## Examples

    iex> Faker.File.file_name(:text)
    "aliquam.txt"
    iex> Faker.File.file_name(:video)
    "sint.mp4"
    iex> Faker.File.file_name(:image)
    "consequatur.bmp"
    iex> Faker.File.file_name(:audio)
    "qui.wav"

## mime_type()

Returns a random mime type

## Examples

    iex> Faker.File.mime_type()
    "text/css"
    iex> Faker.File.mime_type()
    "message/http"
    iex> Faker.File.mime_type()
    "application/ogg"
    iex> Faker.File.mime_type()
    "model/x3d+xml"

## mime_type(category)

Returns a random mime type from the category given
Available categories: :application, :audio, :image, :message, :model,
:multipart, :text, :video

## Examples

    iex> Faker.File.mime_type(:image)
    "image/vnd.microsoft.icon"
    iex> Faker.File.mime_type(:audio)
    "audio/mp4"
    iex> Faker.File.mime_type(:application)
    "application/xop+xml"
    iex> Faker.File.mime_type(:video)
    "video/mpeg"