# JOSE.JWE



## to_record/1

Converts a `JOSE.JWE` struct to a `:jose_jwe` record.

## from_record/1

Converts a `:jose_jwe` record into a `JOSE.JWE`.

## from/1

Converts a binary or map into a `JOSE.JWE`.

    iex> JOSE.JWE.from(%{ "alg" => "dir" })
    %JOSE.JWE{alg: {:jose_jwe_alg_dir, :dir}, enc: :undefined, fields: %{},
     zip: :undefined}
    iex> JOSE.JWE.from("{"alg":"dir"}")
    %JOSE.JWE{alg: {:jose_jwe_alg_dir, :dir}, enc: :undefined, fields: %{},
     zip: :undefined}

There are 3 keys which can have custom modules defined for them:

  * `"alg"` - must implement `:jose_jwe` and `:jose_jwe_alg` behaviours
  * `"enc"` - must implement `:jose_jwe` and `:jose_jwe_enc` behaviours
  * `"zip"` - must implement `:jose_jwe` and `:jose_jwe_zip` behaviours

For example:

    iex> JOSE.JWE.from({%{ zip: MyCustomCompress }, %{ "alg" => "dir", "zip" => "custom" }})
    %JOSE.JWE{alg: {:jose_jwe_alg_dir, :dir}, enc: :undefined, fields: %{},
     zip: {MyCustomCompress, :state}}

## from_binary/1

Converts a binary into a `JOSE.JWE`.

## from_file/1

Reads file and calls `from_binary/1` to convert into a `JOSE.JWE`.

## from_map/1

Converts a map into a `JOSE.JWE`.

## to_binary/1

Converts a `JOSE.JWE` into a binary.

## to_file/2

Calls `to_binary/1` on a `JOSE.JWE` and then writes the binary to file.

## to_map/1

Converts a `JOSE.JWE` into a map.

## block_decrypt/2

Decrypts the `encrypted` binary or map using the `jwk`.

    iex> jwk = JOSE.JWK.from(%{"k" => "STlqtIOhWJjoVnYjUjxFLZ6oN1oB70QARGSTWQ_5XgM", "kty" => "oct"})
    %JOSE.JWK{fields: %{}, keys: :undefined,
     kty: {:jose_jwk_kty_oct,
      <<73, 57, 106, 180, 131, 161, 88, 152, 232, 86, 118, 35, 82, 60, 69, 45, 158, 168, 55, 90, 1, 239, 68, 0, 68, 100, 147, 89, 15, 249, 94, 3>>}}
    iex> JOSE.JWE.block_decrypt(jwk, "eyJhbGciOiJkaXIiLCJlbmMiOiJBMTI4Q0JDLUhTMjU2In0..jBt5tTa1Q0N3uFPEkf30MQ.Ei49MvTLLje7bsZ5EZCZMA.gMWOAmhZSq9ksHCZm6VSoA")
    {"{}",
     %JOSE.JWE{alg: {:jose_jwe_alg_dir, :dir},
      enc: {:jose_jwe_enc_aes,
       {:jose_jwe_enc_aes, {:aes_cbc, 128}, 256, 32, 16, 16, 16, 16, :sha256}},
      fields: %{}, zip: :undefined}}

See `block_encrypt/2`.

## block_encrypt/3

Encrypts `plain_text` using the `jwk` and algorithm specified by the `jwe` by getting the `cek` for `block_encrypt/4`.

## block_encrypt/4

Encrypts `plain_text` using the `jwk`, `cek`, and algorithm specified by the `jwe` by getting the `iv` for `block_encrypt/5`.

## block_encrypt/5

Encrypts the `plain_text` using the `jwk`, `cek`, `iv`, and algorithm specified by the `jwe`.

    iex> jwk = JOSE.JWK.from(%{"k" => "STlqtIOhWJjoVnYjUjxFLZ6oN1oB70QARGSTWQ_5XgM", "kty" => "oct"})
    %JOSE.JWK{fields: %{}, keys: :undefined,
     kty: {:jose_jwk_kty_oct,
      <<73, 57, 106, 180, 131, 161, 88, 152, 232, 86, 118, 35, 82, 60, 69, 45, 158, 168, 55, 90, 1, 239, 68, 0, 68, 100, 147, 89, 15, 249, 94, 3>>}}
    iex> JOSE.JWE.block_encrypt(jwk, "{}", %{ "alg" => "dir", "enc" => "A128CBC-HS256" })
    {%{alg: :jose_jwe_alg_dir, enc: :jose_jwe_enc_aes},
     %{"ciphertext" => "Ei49MvTLLje7bsZ5EZCZMA", "encrypted_key" => "",
       "iv" => "jBt5tTa1Q0N3uFPEkf30MQ",
       "protected" => "eyJhbGciOiJkaXIiLCJlbmMiOiJBMTI4Q0JDLUhTMjU2In0",
       "tag" => "gMWOAmhZSq9ksHCZm6VSoA"}}

See `block_decrypt/2`.

## compress/2

Compresses the `plain_text` using the `"zip"` algorithm specified by the `jwe`.

    iex> JOSE.JWE.compress("{}", %{ "alg" => "dir", "zip" => "DEF" })
    <<120, 156, 171, 174, 5, 0, 1, 117, 0, 249>>

See `uncompress/2`.

## generate_key/1

Generates a new `JOSE.JWK` based on the algorithms of the specified `JOSE.JWE`.

    iex> JOSE.JWE.generate_key(%{"alg" => "dir", "enc" => "A128GCM"})
    %JOSE.JWK{fields: %{"alg" => "dir", "enc" => "A128GCM", "use" => "enc"},
     keys: :undefined,
     kty: {:jose_jwk_kty_oct,
      <<188, 156, 171, 224, 232, 231, 41, 250, 210, 117, 112, 219, 134, 218, 94, 50>>}}

## key_decrypt/3

Decrypts the `encrypted_key` using the `jwk` and the `"alg"` and `"enc"` specified by the `jwe`.

    # let's define our jwk and encrypted_key
    jwk = JOSE.JWK.from(%{"k" => "idN_YyeYZqEE7BkpexhA2Q", "kty" => "oct"})
    enc = <<27, 123, 126, 121, 56, 105, 105, 81, 140, 76, 30, 2, 14, 92, 231, 174, 203, 196, 110, 204, 57, 238, 248, 73>>

    iex> JOSE.JWE.key_decrypt(jwk, enc, %{ "alg" => "A128KW", "enc" => "A128CBC-HS256" })
    <<134, 82, 15, 176, 181, 115, 173, 19, 13, 44, 189, 185, 187, 125, 28, 240>>

See `key_encrypt/3`.

## key_encrypt/3

Encrypts the `decrypted_key` using the `jwk` and the `"alg"` and `"enc"` specified by the `jwe`.

    # let's define our jwk and cek (or decrypted_key)
    jwk = JOSE.JWK.from(%{"k" => "idN_YyeYZqEE7BkpexhA2Q", "kty" => "oct"})            # JOSE.JWK.generate_key({:oct, 16})
    cek = <<134, 82, 15, 176, 181, 115, 173, 19, 13, 44, 189, 185, 187, 125, 28, 240>> # :crypto.rand_bytes(16)

    iex> JOSE.JWE.key_encrypt(jwk, cek, %{ "alg" => "A128KW", "enc" => "A128CBC-HS256" })
    {<<27, 123, 126, 121, 56, 105, 105, 81, 140, 76, 30, 2, 14, 92, 231, 174, 203, 196, 110, 204, 57, 238, 248, 73>>,
     %JOSE.JWE{alg: {:jose_jwe_alg_aes_kw,
       {:jose_jwe_alg_aes_kw, 128, false, :undefined, :undefined}},
      enc: {:jose_jwe_enc_aes,
       {:jose_jwe_enc_aes, {:aes_cbc, 128}, 256, 32, 16, 16, 16, 16, :sha256}},
      fields: %{}, zip: :undefined}}

See `key_decrypt/3`.

## merge/2

Merges map on right into map on left.

## next_cek/2

Returns the next `cek` using the `jwk` and the `"alg"` and `"enc"` specified by the `jwe`.

    # let's define our jwk
    jwk = JOSE.JWK.from(%{"k" => "idN_YyeYZqEE7BkpexhA2Q", "kty" => "oct"}) # JOSE.JWK.generate_key({:oct, 16})

    iex> JOSE.JWE.next_cek(jwk, %{ "alg" => "A128KW", "enc" => "A128CBC-HS256" })
    <<37, 83, 139, 165, 44, 23, 163, 186, 255, 155, 183, 17, 220, 211, 80, 247, 239, 149, 194, 53, 134, 41, 254, 176, 0, 247, 66, 38, 217, 252, 82, 233>>

    # when using the "dir" algorithm, the jwk itself will be used
    iex> JOSE.JWE.next_cek(jwk, %{ "alg" => "dir", "enc" => "A128GCM" })
    <<137, 211, 127, 99, 39, 152, 102, 161, 4, 236, 25, 41, 123, 24, 64, 217>>

## next_iv/1

Returns the next `iv` the `"alg"` and `"enc"` specified by the `jwe`.

    # typically just returns random bytes for the specified "enc" algorithm
    iex> bit_size(JOSE.JWE.next_iv(%{ "alg" => "dir", "enc" => "A128CBC-HS256" }))
    128
    iex> bit_size(JOSE.JWE.next_iv(%{ "alg" => "dir", "enc" => "A128GCM" }))
    96

## uncompress/2

Uncompresses the `cipher_text` using the `"zip"` algorithm specified by the `jwe`.

    iex> JOSE.JWE.uncompress(<<120, 156, 171, 174, 5, 0, 1, 117, 0, 249>>, %{ "alg" => "dir", "zip" => "DEF" })
    "{}"

See `compress/2`.