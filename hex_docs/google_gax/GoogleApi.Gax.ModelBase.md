# GoogleApi.Gax.ModelBase

This module helps you quickly and concisely define API models.

Example:

    defmodule Pet do
      use GoogleApi.Gax.ModelBase

      field(:id)
      field(:category, as: Category)
      field(:tags, as: Tag, type: :list)
    end

## decode/3

Helper to decode model fields

## encode/2

Helper to encode model into JSON