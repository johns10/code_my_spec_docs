# JOSE.JWT



## to_record/1

Converts a `JOSE.JWT` struct to a `:jose_jwt` record.

This also works for converting a list of `JOSE.JWT` structs to a list of `:jose_jwt` records.

## from_record/1

Converts a `:jose_jwt` record into a `JOSE.JWT`.

This also works for converting a list of `:jose_jwt` records into a list of `JOSE.JWT` structs.

## from/1

Converts a binary or map into a `JOSE.JWT`.

    iex> JOSE.JWT.from(%{ "test" => true })
    %JOSE.JWT{fields: %{"test" => true}}
    iex> JOSE.JWT.from("{"test":true}")
    %JOSE.JWT{fields: %{"test" => true}}

## from_binary/1

Converts a binary into a `JOSE.JWT`.

## from_file/1

Reads file and calls `from_binary/1` to convert into a `JOSE.JWT`.

## from_map/1

Converts a map into a `JOSE.JWT`.

## to_binary/1

Converts a `JOSE.JWT` into a binary.

## to_file/2

Calls `to_binary/1` on a `JOSE.JWT` and then writes the binary to file.

## to_map/1

Converts a `JOSE.JWT` into a map.

## decrypt/2

Decrypts an encrypted `JOSE.JWT` using the `jwk`.  See `JOSE.JWE.block_decrypt/2`.

## encrypt/2

Encrypts a `JOSE.JWT` using the `jwk` and the default block encryptor algorithm `jwe` for the key type.  See `encrypt/3`.

## encrypt/3

Encrypts a `JOSE.JWT` using the `jwk` and the `jwe` algorithm.  See `JOSE.JWK.block_encrypt/3`.

If `"typ"` is not specified in the `jwe`, `%{ "typ" => "JWT" }` will be added.

## merge/2

Merges map on right into map on left.

## peek/1

Same as `peek_payload/1`.

## peek_payload/1

Returns the decoded payload as a `JOSE.JWT` of a signed binary or map without verifying the signature.

See `JOSE.JWS.peek_payload/1`.

## peek_protected/1

Returns the decoded protected as a `JOSE.JWS` of a signed binary or map without verifying the signature.

See `JOSE.JWS.peek_protected/1`.

## sign/2

Signs a `JOSE.JWT` using the `jwk` and the default signer algorithm `jws` for the key type.  See `sign/3`.

## sign/3

Signs a `JOSE.JWT` using the `jwk` and the `jws` algorithm.  See `JOSE.JWK.sign/3`.

If `"typ"` is not specified in the `jws`, `%{ "typ" => "JWT" }` will be added.

## verify/2

Verifies the `signed` using the `jwk` and calls `from/1` on the payload.  See `JOSE.JWS.verify/2`.

## verify_strict/3

Verifies the `signed` using the `jwk`, whitelists the `"alg"` using `allow`, and calls `from/1` on the payload.  See `JOSE.JWS.verify_strict/3`.