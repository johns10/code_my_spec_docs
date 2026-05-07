# JOSE.JWT

JWT stands for JSON Web Token which is defined in [RFC 7519](https://tools.ietf.org/html/rfc7519).

## Encryption Examples

## Signature Examples

All of the example keys generated below can be found here: [https://gist.github.com/potatosalad/925a8b74d85835e285b9](https://gist.github.com/potatosalad/925a8b74d85835e285b9)

See `JOSE.JWS` for more Signature examples.  For security purposes, `verify_strict/3` is recommended over `verify/2`.

### HS256

    # let's generate the key we'll use below and define our jwt
    jwk_hs256 = JOSE.JWK.generate_key({:oct, 16})
    jwt       = %{ "test" => true }

    # HS256
    iex> signed_hs256 = JOSE.JWT.sign(jwk_hs256, %{ "alg" => "HS256" }, jwt) |> JOSE.JWS.compact |> elem(1)
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0ZXN0Ijp0cnVlfQ.XYsFJDhfBZCAKnEZjR0WWd1l1ZPDD4bYpZYMHizexfQ"
    # verify_strict/3 is recommended over verify/2
    iex> JOSE.JWT.verify_strict(jwk_hs256, ["HS256"], signed_hs256)
    {true, %JOSE.JWT{fields: %{"test" => true}},
     %JOSE.JWS{alg: {:jose_jws_alg_hmac, {:jose_jws_alg_hmac, :sha256}},
      b64: :undefined, fields: %{"typ" => "JWT"}}}
    # verify/2 returns the same thing without "alg" whitelisting
    iex> JOSE.JWT.verify(jwk_hs256, signed_hs256)
    {true, %JOSE.JWT{fields: %{"test" => true}},
     %JOSE.JWS{alg: {:jose_jws_alg_hmac, {:jose_jws_alg_hmac, :sha256}},
      b64: :undefined, fields: %{"typ" => "JWT"}}}

    # the default signing algorithm is also "HS256" based on the type of jwk used
    iex> signed_hs256 == JOSE.JWT.sign(jwk_hs256, jwt) |> JOSE.JWS.compact |> elem(1)
    true

## decrypt(jwk, encrypted)

Decrypts an encrypted `JOSE.JWT` using the `jwk`.  See `JOSE.JWE.block_decrypt/2`.

## encrypt(jwk, jwt)

Encrypts a `JOSE.JWT` using the `jwk` and the default block encryptor algorithm `jwe` for the key type.  See `encrypt/3`.

## encrypt(jwk, jwe, jwt)

Encrypts a `JOSE.JWT` using the `jwk` and the `jwe` algorithm.  See `JOSE.JWK.block_encrypt/3`.

If `"typ"` is not specified in the `jwe`, `%{ "typ" => "JWT" }` will be added.

## from(list)

Converts a binary or map into a `JOSE.JWT`.

    iex> JOSE.JWT.from(%{ "test" => true })
    %JOSE.JWT{fields: %{"test" => true}}
    iex> JOSE.JWT.from("{"test":true}")
    %JOSE.JWT{fields: %{"test" => true}}

## from_binary(list)

Converts a binary into a `JOSE.JWT`.

## from_file(file)

Reads file and calls `from_binary/1` to convert into a `JOSE.JWT`.

## from_map(list)

Converts a map into a `JOSE.JWT`.

## from_record(jose_jwt)

Converts a `:jose_jwt` record into a `JOSE.JWT`.

This also works for converting a list of `:jose_jwt` records into a list of `JOSE.JWT` structs.

## merge(left, right)

Merges map on right into map on left.

## peek(signed)

Same as `peek_payload/1`.

## peek_payload(signed)

Returns the decoded payload as a `JOSE.JWT` of a signed binary or map without verifying the signature.

See `JOSE.JWS.peek_payload/1`.

## peek_protected(signed)

Returns the decoded protected as a `JOSE.JWS` of a signed binary or map without verifying the signature.

See `JOSE.JWS.peek_protected/1`.

## sign(jwk, jwt)

Signs a `JOSE.JWT` using the `jwk` and the default signer algorithm `jws` for the key type.  See `sign/3`.

## sign(jwk, jws, jwt)

Signs a `JOSE.JWT` using the `jwk` and the `jws` algorithm.  See `JOSE.JWK.sign/3`.

If `"typ"` is not specified in the `jws`, `%{ "typ" => "JWT" }` will be added.

## to_binary(list)

Converts a `JOSE.JWT` into a binary.

## to_file(file, jwt)

Calls `to_binary/1` on a `JOSE.JWT` and then writes the binary to file.

## to_map(list)

Converts a `JOSE.JWT` into a map.

## to_record(jose_jwt)

Converts a `JOSE.JWT` struct to a `:jose_jwt` record.

This also works for converting a list of `JOSE.JWT` structs to a list of `:jose_jwt` records.

## verify(jwk, signed)

Verifies the `signed` using the `jwk` and calls `from/1` on the payload.  See `JOSE.JWS.verify/2`.

## verify_strict(jwk, allow, signed)

Verifies the `signed` using the `jwk`, whitelists the `"alg"` using `allow`, and calls `from/1` on the payload.  See `JOSE.JWS.verify_strict/3`.