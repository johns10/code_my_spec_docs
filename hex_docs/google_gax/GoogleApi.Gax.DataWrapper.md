# GoogleApi.Gax.DataWrapper

Module and struct to help serialize/deserialize "data-wrapped" responses.

An endpoint response may be declared as type "Pet" and "data-wrapped" which
means the response would have an outer object with a single "data" key:

    {
      "data": { // real pet data
        "id": 123,
        "name": "Fido"
      }
    }

## decode(data_wrapper, options)

Unwrap a data-wrapped JSON response.

## Examples

    iex> GoogleApi.Gax.DataWrapper.decode(%GoogleApi.Gax.DataWrapper{data: %{"id" => 123, "name" => "Fido"}}, struct: %TestClient.Model.Pet{})
    %TestClient.Model.Pet{id: 123, name: "Fido"}