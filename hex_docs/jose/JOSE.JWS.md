# JOSE.JWS



## to_record/1

Converts a `JOSE.JWS` struct to a `:jose_jws` record.

## from_record/1

Converts a `:jose_jws` record into a `JOSE.JWS`.

## from/1

Converts a binary or map into a `JOSE.JWS`.

    iex> JOSE.JWS.from(%{ "alg" => "HS256" })
    %JOSE.JWS{alg: {:jose_jws_alg_hmac, :HS256}, b64: :undefined, fields: %{}}
    iex> JOSE.JWS.from("{"alg":"HS256"}")
    %JOSE.JWS{alg: {:jose_jws_alg_hmac, :HS256}, b64: :undefined, fields: %{}}

Support for custom algorithms may be added by specifying a map tuple:

    iex> JOSE.JWS.from({%{ alg: MyCustomAlgorithm }, %{ "alg" => "custom" }})
    %JOSE.JWS{alg: {MyCustomAlgorithm, :state}, b64: :undefined, fields: %{}}

*Note:* `MyCustomAlgorithm` must implement the `:jose_jws` and `:jose_jws_alg` behaviours.

## from_binary/1

Converts a binary into a `JOSE.JWS`.

## from_file/1

Reads file and calls `from_binary/1` to convert into a `JOSE.JWS`.

## from_map/1

Converts a map into a `JOSE.JWS`.

## to_binary/1

Converts a `JOSE.JWS` into a binary.

## to_file/2

Calls `to_binary/1` on a `JOSE.JWS` and then writes the binary to file.

## to_map/1

Converts a `JOSE.JWS` into a map.

## generate_key/1

Generates a new `JOSE.JWK` based on the algorithms of the specified `JOSE.JWS`.

    iex> JOSE.JWS.generate_key(%{"alg" => "HS256"})
    %JOSE.JWK{fields: %{"alg" => "HS256", "use" => "sig"},
     keys: :undefined,
     kty: {:jose_jwk_kty_oct,
      <<150, 71, 29, 79, 228, 32, 218, 4, 111, 250, 212, 129, 226, 173, 86, 205, 72, 48, 98, 100, 66, 68, 113, 13, 43, 60, 122, 248, 179, 44, 140, 24>>}}

## merge/2

Merges map on right into map on left.

## sign/3

Signs the `plain_text` using the `jwk` and algorithm specified by the `jws`.

    iex> jwk = JOSE.JWK.from(%{"k" => "qUg4Yw", "kty" => "oct"})
    %JOSE.JWK{fields: %{}, keys: :undefined,
     kty: {:jose_jwk_kty_oct, <<169, 72, 56, 99>>}}
    iex> JOSE.JWS.sign(jwk, "{}", %{ "alg" => "HS256" })
    {%{alg: :jose_jws_alg_hmac},
     %{"payload" => "e30", "protected" => "eyJhbGciOiJIUzI1NiJ9",
       "signature" => "5paAJxaOXSqRUIXrP_vJXUZu2SCBH-ojgP4D6Xr6GPU"}}

If the `jwk` has a `"kid"` assigned, it will be added to the `"header"` on the signed map:

    iex> jwk = JOSE.JWK.from(%{"k" => "qUg4Yw", "kid" => "eyHC48MN26DvoBpkaudvOVXuI5Sy8fKMxQMYiRWmjFw", "kty" => "oct"})
    %JOSE.JWK{fields: %{"kid" => "eyHC48MN26DvoBpkaudvOVXuI5Sy8fKMxQMYiRWmjFw"},
     keys: :undefined, kty: {:jose_jwk_kty_oct, <<169, 72, 56, 99>>}}
    iex> JOSE.JWS.sign(jwk, "test", %{ "alg" => "HS256" })
    {%{alg: :jose_jws_alg_hmac},
     %{"header" => %{"kid" => "eyHC48MN26DvoBpkaudvOVXuI5Sy8fKMxQMYiRWmjFw"},
       "payload" => "e30", "protected" => "eyJhbGciOiJIUzI1NiJ9",
       "signature" => "5paAJxaOXSqRUIXrP_vJXUZu2SCBH-ojgP4D6Xr6GPU"}}

A list of `jwk` keys can also be specified to produce a signed list:

    iex> jwk1 = JOSE.JWK.from(%{"k" => "qUg4Yw", "kty" => "oct"})
    %JOSE.JWK{fields: %{}, keys: :undefined,
     kty: {:jose_jwk_kty_oct, <<169, 72, 56, 99>>}}
    iex> jwk2 = JOSE.JWK.from_map(%{"k" => "H-v_Nw", "kty" => "oct"})
    %JOSE.JWK{fields: %{}, keys: :undefined,
     kty: {:jose_jwk_kty_oct, <<31, 235, 255, 55>>}}
    iex> JOSE.JWS.sign([jwk1, jwk2], "{}", %{ "alg" => "HS256" })
    {%{alg: :jose_jws_alg_hmac},
     %{"payload" => "e30",
       "signatures" => [
        %{"protected" => "eyJhbGciOiJIUzI1NiJ9",
          "signature" => "5paAJxaOXSqRUIXrP_vJXUZu2SCBH-ojgP4D6Xr6GPU"},
        %{"protected" => "eyJhbGciOiJIUzI1NiJ9",
          "signature" => "himAUXqVJnW2ZWOD8zaOZr0YzsA61lo48wu6-WP-Ks0"}]}}

*Note:* Signed maps with a `"header"` or other fields will have data loss when used with `compact/1`.

## sign/4

Signs the `plain_text` using the `jwk` and algorithm specified by the `jws` and adds the `header` to the signed map.

    iex> jwk = JOSE.JWK.from(%{"k" => "qUg4Yw", "kty" => "oct"})
    %JOSE.JWK{fields: %{}, keys: :undefined,
     kty: {:jose_jwk_kty_oct, <<169, 72, 56, 99>>}}
    iex> JOSE.JWS.sign(jwk, "{}", %{ "test" => true }, %{ "alg" => "HS256" })
    {%{alg: :jose_jws_alg_hmac},
     %{"header" => %{"test" => true}, "payload" => "e30",
       "protected" => "eyJhbGciOiJIUzI1NiJ9",
       "signature" => "5paAJxaOXSqRUIXrP_vJXUZu2SCBH-ojgP4D6Xr6GPU"}}

If the `jwk` has a `"kid"` assigned, it will be added to the `"header"` on the signed map.  See `sign/3`.

## signing_input/2

Converts the `jws` to the `protected` argument used by `signing_input/3`.

## signing_input/3

Combines `payload` and `protected` based on the `"b64"` setting on the `jws` for the signing input used by `sign/3` and `sign/4`.

If `"b64"` is set to `false` on the `jws`, the raw `payload` will be used:

    iex> JOSE.JWS.signing_input("{}", %{ "alg" => "HS256" })
    "eyJhbGciOiJIUzI1NiJ9.e30"
    iex> JOSE.JWS.signing_input("{}", %{ "alg" => "HS256", "b64" => false })
    "eyJhbGciOiJIUzI1NiIsImI2NCI6ZmFsc2V9.{}"

See [JWS Unencoded Payload Option](https://tools.ietf.org/html/draft-ietf-jose-jws-signing-input-options-04) for more information.

## verify/2

Verifies the `signed` using the `jwk`.

    iex> jwk = JOSE.JWK.from(%{"k" => "qUg4Yw", "kty" => "oct"})
    %JOSE.JWK{fields: %{}, keys: :undefined,
     kty: {:jose_jwk_kty_oct, <<169, 72, 56, 99>>}}
    iex> JOSE.JWS.verify(jwk, "eyJhbGciOiJIUzI1NiJ9.e30.5paAJxaOXSqRUIXrP_vJXUZu2SCBH-ojgP4D6Xr6GPU")
    {true, "{}",
     %JOSE.JWS{alg: {:jose_jws_alg_hmac, :HS256}, b64: :undefined, fields: %{}}}

A list of `jwk` keys can also be specified where each key will be used to verify every entry in a signed list:

    iex> jwk1 = JOSE.JWK.from(%{"k" => "qUg4Yw", "kty" => "oct"})
    %JOSE.JWK{fields: %{}, keys: :undefined,
     kty: {:jose_jwk_kty_oct, <<169, 72, 56, 99>>}}
    iex> jwk2 = JOSE.JWK.from_map(%{"k" => "H-v_Nw", "kty" => "oct"})
    %JOSE.JWK{fields: %{}, keys: :undefined,
     kty: {:jose_jwk_kty_oct, <<31, 235, 255, 55>>}}
    iex> JOSE.JWS.verify([jwk1, jwk2], %{"payload" => "e30",
     "signatures" => [
      %{"protected" => "eyJhbGciOiJIUzI1NiJ9",
        "signature" => "5paAJxaOXSqRUIXrP_vJXUZu2SCBH-ojgP4D6Xr6GPU"},
      %{"protected" => "eyJhbGciOiJIUzI1NiJ9",
        "signature" => "himAUXqVJnW2ZWOD8zaOZr0YzsA61lo48wu6-WP-Ks0"}]})
    [{%JOSE.JWK{fields: %{}, keys: :undefined,
       kty: {:jose_jwk_kty_oct, <<169, 72, 56, 99>>}},
      [{true, "{}",
        %JOSE.JWS{alg: {:jose_jws_alg_hmac, :HS256}, b64: :undefined, fields: %{}}},
       {false, "{}",
        %JOSE.JWS{alg: {:jose_jws_alg_hmac, :HS256}, b64: :undefined,
         fields: %{}}}]},
     {%JOSE.JWK{fields: %{}, keys: :undefined,
       kty: {:jose_jwk_kty_oct, <<31, 235, 255, 55>>}},
      [{false, "{}",
        %JOSE.JWS{alg: {:jose_jws_alg_hmac, :HS256}, b64: :undefined, fields: %{}}},
       {true, "{}",
        %JOSE.JWS{alg: {:jose_jws_alg_hmac, :HS256}, b64: :undefined,
         fields: %{}}}]}]

## verify_strict/3

Same as `verify/2`, but uses `allow` as a whitelist for `"alg"` which are allowed to verify against.

If the detected algorithm is not present in `allow`, then `false` is returned.

    iex> jwk = JOSE.JWK.from(%{"k" => "qUg4Yw", "kty" => "oct"})
    %JOSE.JWK{fields: %{}, keys: :undefined,
     kty: {:jose_jwk_kty_oct, <<169, 72, 56, 99>>}}
    iex> signed_hs256 = JOSE.JWS.sign(jwk, "{}", %{ "alg" => "HS256" }) |> JOSE.JWS.compact |> elem(1)
    "eyJhbGciOiJIUzI1NiJ9.e30.5paAJxaOXSqRUIXrP_vJXUZu2SCBH-ojgP4D6Xr6GPU"
    iex> signed_hs512 = JOSE.JWS.sign(jwk, "{}", %{ "alg" => "HS512" }) |> JOSE.JWS.compact |> elem(1)
    "eyJhbGciOiJIUzUxMiJ9.e30.DN_JCks5rzQiDJJ15E6uJFskAMw-KcasGINKK_4S8xKo7W6tZ-a00ZL8UWOWgE7oHpcFrYnvSpNRldAMp19iyw"
    iex> JOSE.JWS.verify_strict(jwk, ["HS256"], signed_hs256) |> elem(0)
    true
    iex> JOSE.JWS.verify_strict(jwk, ["HS256"], signed_hs512) |> elem(0)
    false
    iex> JOSE.JWS.verify_strict(jwk, ["HS256", "HS512"], signed_hs512) |> elem(0)
    true