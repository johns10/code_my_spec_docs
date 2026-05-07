# JOSE.JWK

JWK stands for JSON Web Key which is defined in [RFC 7517](https://tools.ietf.org/html/rfc7517).

## block_decrypt(encrypted, jwk)

Decrypts the `encrypted` binary or map using the `jwk`.  See `JOSE.JWE.block_decrypt/2`.

## block_encrypt(plain_text, jwk)

Encrypts the `plain_text` using the `jwk` and the default `jwe` based on the key type.  See `block_encrypt/3`.

## block_encrypt(plain_text, jwe, jwk)

Encrypts the `plain_text` using the `jwk` and algorithms specified by the `jwe`.  See `JOSE.JWE.block_encrypt/3`.

## block_encryptor(list)

Returns a block encryptor map for the key type.

## box_decrypt_ecdh_1pu(encrypted, u_static_public_key, v_static_secret_key)

ECDH-1PU Key Agreement decryption of the `encrypted` binary or map using `u_static_public_key` and `v_static_secret_key`.  See `box_encrypt_ecdh_1pu/3` and `JOSE.JWE.block_decrypt/2`.

## box_decrypt_ecdh_es(encrypted, v_static_secret_key)

ECDH-ES Key Agreement decryption of the `encrypted` binary or map using `v_static_secret_key`.  See `box_encrypt_ecdh_es/2` and `JOSE.JWE.block_decrypt/2`.

## box_decrypt_ecdh_ss(encrypted, v_static_secret_key)

ECDH-SS Key Agreement decryption of the `encrypted` binary or map using `v_static_secret_key`.  See `box_encrypt_ecdh_ss/2` and `JOSE.JWE.block_decrypt/2`.

## box_encrypt_ecdh_1pu(plain_text, v_static_public_key, u_static_secret_key)

ECDH-1PU Key Agreement encryption of `plain_text` by generating an ephemeral secret key based on `v_static_public_key` and `u_static_secret_key` curve.  See `box_encrypt_ecdh_1pu/4`.

    # Alice (U) wants to send Bob (V) a secret message.
    # They have already shared their static public keys with one another through an unspecified channel:
    u_static_public_key = JOSE.JWK.from(%{
      "crv" => "X25519",
      "kty" => "OKP",
      "x" => "sz1JMMasNRLQfXIkvLTRaOu978QQu1roFKxBPKZdsC8"
    })
    v_static_public_key = JOSE.JWK.from(%{
      "crv" => "X25519",
      "kty" => "OKP",
      "x" => "EFvrJluQClNDvbIjcie4UADLfirR9Fk53rcSM5gibx4"
    })

    # WARNING: Do not share secret keys.  For reference purposes only, here is Alice's (U) static secret key that is used below:
    u_static_secret_key = JOSE.JWK.from(%{
      "crv" => "X25519",
      "d" => "SfYmE8aLpvX6Z0rZQVa5eBjLKeINUfSlu-_AcYJXCqQ",
      "kty" => "OKP",
      "x" => "sz1JMMasNRLQfXIkvLTRaOu978QQu1roFKxBPKZdsC8"
    })
    # WARNING: Do not share secret keys.  For reference purposes only, here is Bob's (V) static secret key that is used below:
    v_static_secret_key = JOSE.JWK.from(%{
      "crv" => "X25519",
      "d" => "8-SdA6TQ1mdFRC06U-R4-ah6YkeVcodtGuMNVngwlto",
      "kty" => "OKP",
      "x" => "EFvrJluQClNDvbIjcie4UADLfirR9Fk53rcSM5gibx4"
    })

    # Alice (U) uses Bob's (V) static public key along with Alice's (U) static secret key to generate an ephemeral secret key used to encrypt the message:
    iex> {enc_alice2bob_tuple, u_ephemeral_secret_key} = JOSE.JWK.box_encrypt_ecdh_1pu("secret message", v_static_public_key, u_static_secret_key)
    {{%{alg: :jose_jwe_alg_ecdh_1pu, enc: :jose_jwe_enc_aes},
      %{
        "ciphertext" => "Ry0I26YMnaHSmNQ86EY",
        "encrypted_key" => "",
        "iv" => "swK08mi6cjJ1aUQF",
        "protected" => "eyJhbGciOiJFQ0RILTFQVSIsImFwdSI6IjAybXM0OF90ZmpqQXk4TXJMeDV1LW1yaVZwT24tOFpNVmtDTXlIbEtBTjAiLCJhcHYiOiJrNDR0QzE4U2tYTUVXektFQ0JSZ3VhMHpaX01MRHY1VTQ2TWNueVl6ajBBIiwiZW5jIjoiQTEyOEdDTSIsImVwayI6eyJjcnYiOiJYMjU1MTkiLCJrdHkiOiJPS1AiLCJ4IjoiX3JBS1l6WThJczFSRXJQTTVod29OSEZjdWZQOHpiYXpVaTN5QXJ3WnVDVSJ9LCJza2lkIjoieXNZVzZiUmRpVW1ST0NWa09oSmtWMV9JX0VEM1dESzBIN2tkbU5GelNYSSJ9",
        "tag" => "-6PitRlVuXk5HT3g_y6Uxw"
      }},
     %JOSE.JWK{
       keys: :undefined,
       kty: {:jose_jwk_kty_okp_x25519,
        <<30, 250, 220, 248, 158, 207, 86, 211, 254, 196, 78, 125, 132, 228, 186, 20, 253, 56, 226, 29, 191, 220, 131, 114, 44, 253, 72, 117, 25, 112, 209, 175, 254, 176, 10, 99, 54, 60, 34, 205, 81, 18, 179, 204, 230, 28, 40, 52, 113, 92, 185, 243, 252, 205, 182, 179, 82, 45, 242, 2, 188, 25, 184, 37>>},
       fields: %{}
     }}

    # Alice (U) compacts the encrypted message and sends it to Bob (V), which contains Alice's (U) ephemeral public key:
    iex> enc_alice2bob_binary = JOSE.JWE.compact(enc_alice2bob_tuple) |> elem(1)
    "eyJhbGciOiJFQ0RILTFQVSIsImFwdSI6IjAybXM0OF90ZmpqQXk4TXJMeDV1LW1yaVZwT24tOFpNVmtDTXlIbEtBTjAiLCJhcHYiOiJrNDR0QzE4U2tYTUVXektFQ0JSZ3VhMHpaX01MRHY1VTQ2TWNueVl6ajBBIiwiZW5jIjoiQTEyOEdDTSIsImVwayI6eyJjcnYiOiJYMjU1MTkiLCJrdHkiOiJPS1AiLCJ4IjoiX3JBS1l6WThJczFSRXJQTTVod29OSEZjdWZQOHpiYXpVaTN5QXJ3WnVDVSJ9LCJza2lkIjoieXNZVzZiUmRpVW1ST0NWa09oSmtWMV9JX0VEM1dESzBIN2tkbU5GelNYSSJ9..swK08mi6cjJ1aUQF.Ry0I26YMnaHSmNQ86EY.-6PitRlVuXk5HT3g_y6Uxw"

    # Bob (V) can then decrypt the encrypted message using Alice's (U) static public key along with Bob's (V) static secret key:
    iex> JOSE.JWK.box_decrypt_ecdh_1pu(enc_alice2bob_binary, u_static_public_key, v_static_secret_key)
    {"secret message",
     %JOSE.JWE{
       alg: {:jose_jwe_alg_ecdh_1pu,
        {:jose_jwe_alg_ecdh_1pu,
         {:jose_jwk, :undefined,
          {:jose_jwk_kty_okp_x25519,
           <<254, 176, 10, 99, 54, 60, 34, 205, 81, 18, 179, 204, 230, 28, 40, 52, 113, 92, 185, 243, 252, 205, 182, 179, 82, 45, 242, 2, 188, 25, 184, 37>>}, %{}},
         <<211, 105, 172, 227, 207, 237, 126, 56, 192, 203, 195, 43, 47, 30, 110, 250, 106, 226, 86, 147, 167, 251, 198, 76, 86, 64, 140, 200, 121, 74, 0, 221>>,
         <<147, 142, 45, 11, 95, 18, 145, 115, 4, 91, 50, 132, 8, 20, 96, 185, 173, 51, 103, 243, 11, 14, 254, 84, 227, 163, 28, 159, 38, 51, 143, 64>>, :undefined, :undefined, :undefined, :undefined}},
       enc: {:jose_jwe_enc_aes,
        {:jose_jwe_enc_aes, {:aes_gcm, 128}, 128, 16, 12, :undefined, :undefined, :undefined, :undefined}},
       zip: :undefined,
       fields: %{"skid" => "ysYW6bRdiUmROCVkOhJkV1_I_ED3WDK0H7kdmNFzSXI"}
     }}

## box_encrypt_ecdh_1pu(plain_text, v_static_public_key, u_static_secret_key, u_ephemeral_secret_key)

ECDH-1PU Key Agreement encryption of `plain_text` using `v_static_public_key`, `u_static_secret_key`, `u_ephemeral_secret_key`, and a derived `jwe` based on the input key types.  See `box_encrypt_ecdh_1pu/5`.

## box_encrypt_ecdh_1pu(plain_text, jwe, v_static_public_key, u_static_secret_key, u_ephemeral_secret_key)

ECDH-1PU Key Agreement encryption of `plain_text` using `v_static_public_key`, `u_static_secret_key`, `u_ephemeral_secret_key`, and the algorithms specified by the `jwe`.

## box_encrypt_ecdh_es(plain_text, v_static_public_key)

ECDH-ES Key Agreement encryption of `plain_text` by generating an ephemeral secret key based on `v_static_public_key` curve.  See `box_encrypt_ecdh_es/3`.

    # Alice (U) wants to send Bob (V) a secret message.
    # Bob (V) has already shared their static public key with Alice (U) through an unspecified channel:
    v_static_public_key = JOSE.JWK.from(%{
      "crv" => "X25519",
      "kty" => "OKP",
      "x" => "EFvrJluQClNDvbIjcie4UADLfirR9Fk53rcSM5gibx4"
    })

    # WARNING: Do not share secret keys.  For reference purposes only, here is Bob's (V) static secret key that is used below:
    v_static_secret_key = JOSE.JWK.from(%{
      "crv" => "X25519",
      "d" => "8-SdA6TQ1mdFRC06U-R4-ah6YkeVcodtGuMNVngwlto",
      "kty" => "OKP",
      "x" => "EFvrJluQClNDvbIjcie4UADLfirR9Fk53rcSM5gibx4"
    })

    # Alice (U) uses Bob's (V) static public key to generate an ephemeral secret key used to encrypt the message:
    iex> {enc_alice2bob_tuple, u_ephemeral_secret_key} = JOSE.JWK.box_encrypt_ecdh_es("secret message", v_static_public_key)
    {{%{alg: :jose_jwe_alg_ecdh_es, enc: :jose_jwe_enc_aes},
      %{
        "ciphertext" => "AhQ3W31vvypJNubhD2U",
        "encrypted_key" => "",
        "iv" => "YjojFg2wPnk5JmMG",
        "protected" => "eyJhbGciOiJFQ0RILUVTIiwiYXB1IjoiRHNVZlFNdUEybnZqMnRzTVp1N0o5YUFEekw3akUyRFUzRWFvVTh3YmJlVSIsImFwdiI6Ims0NHRDMThTa1hNRVd6S0VDQlJndWEwelpfTUxEdjVVNDZNY255WXpqMEEiLCJlbmMiOiJBMTI4R0NNIiwiZXBrIjp7ImNydiI6IlgyNTUxOSIsImt0eSI6Ik9LUCIsIngiOiJwRkg3YXZYQlFvUjBoZnNsUm1HaVJxREpxdUVjS0w0eTU4TEZocnc1S3dFIn19",
        "tag" => "pwRKlhhXEPjwZg13455U5Q"
      }},
     %JOSE.JWK{
       keys: :undefined,
       kty: {:jose_jwk_kty_okp_x25519,
        <<68, 178, 96, 158, 87, 182, 26, 216, 211, 230, 115, 239, 145, 244, 93, 4, 79, 231, 189, 5, 96, 164, 241, 132, 123, 151, 253, 19, 109, 246, 211, 86, 164, 81, 251, 106, 245, 193, 66, 132, 116, 133, 251, 37, 70, 97, 162, 70, 160, 201, 170, 225, 28, 40, 190, 50, 231, 194, 197, 134, 188, 57, 43, 1>>},
       fields: %{}
     }}

    # Alice (U) compacts the encrypted message and sends it to Bob (V), which contains Alice's (U) ephemeral public key:
    iex> enc_alice2bob_binary = JOSE.JWE.compact(enc_alice2bob_tuple) |> elem(1)
    "eyJhbGciOiJFQ0RILUVTIiwiYXB1IjoiRHNVZlFNdUEybnZqMnRzTVp1N0o5YUFEekw3akUyRFUzRWFvVTh3YmJlVSIsImFwdiI6Ims0NHRDMThTa1hNRVd6S0VDQlJndWEwelpfTUxEdjVVNDZNY255WXpqMEEiLCJlbmMiOiJBMTI4R0NNIiwiZXBrIjp7ImNydiI6IlgyNTUxOSIsImt0eSI6Ik9LUCIsIngiOiJwRkg3YXZYQlFvUjBoZnNsUm1HaVJxREpxdUVjS0w0eTU4TEZocnc1S3dFIn19..YjojFg2wPnk5JmMG.AhQ3W31vvypJNubhD2U.pwRKlhhXEPjwZg13455U5Q"

    # Bob (V) can then decrypt the encrypted message with Bob's (V) static secret key:
    iex> JOSE.JWK.box_decrypt_ecdh_es(enc_alice2bob_binary, v_static_secret_key)
    {"secret message",
     %JOSE.JWE{
       alg: {:jose_jwe_alg_ecdh_es,
        {:jose_jwe_alg_ecdh_es,
         {:jose_jwk, :undefined,
          {:jose_jwk_kty_okp_x25519,
           <<164, 81, 251, 106, 245, 193, 66, 132, 116, 133, 251, 37, 70, 97, 162, 70, 160, 201, 170, 225, 28, 40, 190, 50, 231, 194, 197, 134, 188, 57, 43, 1>>}, %{}},
         <<14, 197, 31, 64, 203, 128, 218, 123, 227, 218, 219, 12, 102, 238, 201, 245, 160, 3, 204, 190, 227, 19, 96, 212, 220, 70, 168, 83, 204, 27, 109, 229>>,
         <<147, 142, 45, 11, 95, 18, 145, 115, 4, 91, 50, 132, 8, 20, 96, 185, 173, 51, 103, 243, 11, 14, 254, 84, 227, 163, 28, 159, 38, 51, 143, 64>>, :undefined, :undefined, :undefined, :undefined}},
       enc: {:jose_jwe_enc_aes,
        {:jose_jwe_enc_aes, {:aes_gcm, 128}, 128, 16, 12, :undefined, :undefined, :undefined, :undefined}},
       zip: :undefined,
       fields: %{}
     }}

## box_encrypt_ecdh_es(plain_text, v_static_public_key, u_ephemeral_secret_key)

ECDH-ES Key Agreement encryption of `plain_text` using `v_static_public_key`, `u_ephemeral_secret_key`, and a derived `jwe` based on the input key types.  See `box_encrypt_ecdh_es/4`.

## box_encrypt_ecdh_es(plain_text, jwe, v_static_public_key, u_ephemeral_secret_key)

ECDH-ES Key Agreement encryption of `plain_text` using `v_static_public_key`, `u_ephemeral_secret_key`, and the algorithms specified by the `jwe`.

## box_encrypt_ecdh_ss(plain_text, v_static_public_key)

ECDH-SS Key Agreement encryption of `plain_text` by generating a static secret key based on `v_static_public_key` curve.  See `box_encrypt_ecdh_ss/3`.

    # Alice (U) wants to send Bob (V) a secret message.
    # Bob (V) has already shared their static public key with Alice (U) through an unspecified channel:
    v_static_public_key = JOSE.JWK.from(%{
      "crv" => "X25519",
      "kty" => "OKP",
      "x" => "EFvrJluQClNDvbIjcie4UADLfirR9Fk53rcSM5gibx4"
    })

    # WARNING: Do not share secret keys.  For reference purposes only, here is Alice's (U) static secret key that is used below:
    u_static_secret_key = JOSE.JWK.from(%{
      "crv" => "X25519",
      "d" => "SfYmE8aLpvX6Z0rZQVa5eBjLKeINUfSlu-_AcYJXCqQ",
      "kty" => "OKP",
      "x" => "sz1JMMasNRLQfXIkvLTRaOu978QQu1roFKxBPKZdsC8"
    })
    # WARNING: Do not share secret keys.  For reference purposes only, here is Bob's (V) static secret key that is used below:
    v_static_secret_key = JOSE.JWK.from(%{
      "crv" => "X25519",
      "d" => "8-SdA6TQ1mdFRC06U-R4-ah6YkeVcodtGuMNVngwlto",
      "kty" => "OKP",
      "x" => "EFvrJluQClNDvbIjcie4UADLfirR9Fk53rcSM5gibx4"
    })

    # Alice (U) uses Bob's (V) static public key and Alice's (U) static secret key to encrypt the message:
    iex> enc_alice2bob_tuple = JOSE.JWK.box_encrypt_ecdh_ss("secret message", v_static_public_key, u_static_secret_key)
    {%{alg: :jose_jwe_alg_ecdh_ss, enc: :jose_jwe_enc_aes}, %{
       "ciphertext" => "yug6TzZUgAEt0DAPNnw",
       "encrypted_key" => "",
       "iv" => "f3rEdLgkLLXqDjno",
       "protected" => "eyJhbGciOiJFQ0RILVNTIiwiYXB1IjoieG1RUUNGbzk5OF9TVzhkMy1vQnRMX0ZfbGtBd1E0Y1J0VHZSRWtlUjBaVTdNR2Q0SkZqSHczR2t1dVdXNFI5YzJDSWkzQzQtQW84NFRzR2x5c0JOMVEiLCJhcHYiOiJrNDR0QzE4U2tYTUVXektFQ0JSZ3VhMHpaX01MRHY1VTQ2TWNueVl6ajBBIiwiZW5jIjoiQTEyOEdDTSIsInNwayI6eyJjcnYiOiJYMjU1MTkiLCJrdHkiOiJPS1AiLCJ4Ijoic3oxSk1NYXNOUkxRZlhJa3ZMVFJhT3U5NzhRUXUxcm9GS3hCUEtaZHNDOCJ9fQ",
       "tag" => "gAszp6UPSNozXeoqk428Og"
     }}

    # Alice (U) compacts the encrypted message and sends it to Bob (V), which contains Alice's (U) static public key:
    iex> enc_alice2bob_binary = JOSE.JWE.compact(enc_alice2bob_tuple) |> elem(1)
    "eyJhbGciOiJFQ0RILVNTIiwiYXB1IjoieG1RUUNGbzk5OF9TVzhkMy1vQnRMX0ZfbGtBd1E0Y1J0VHZSRWtlUjBaVTdNR2Q0SkZqSHczR2t1dVdXNFI5YzJDSWkzQzQtQW84NFRzR2x5c0JOMVEiLCJhcHYiOiJrNDR0QzE4U2tYTUVXektFQ0JSZ3VhMHpaX01MRHY1VTQ2TWNueVl6ajBBIiwiZW5jIjoiQTEyOEdDTSIsInNwayI6eyJjcnYiOiJYMjU1MTkiLCJrdHkiOiJPS1AiLCJ4Ijoic3oxSk1NYXNOUkxRZlhJa3ZMVFJhT3U5NzhRUXUxcm9GS3hCUEtaZHNDOCJ9fQ..f3rEdLgkLLXqDjno.yug6TzZUgAEt0DAPNnw.gAszp6UPSNozXeoqk428Og"

    # Bob (V) can then decrypt the encrypted message with Bob's (V) static secret key:
    iex> JOSE.JWK.box_decrypt_ecdh_ss(enc_alice2bob_binary, v_static_secret_key)
    {"secret message",
     %JOSE.JWE{
       alg: {:jose_jwe_alg_ecdh_ss,
        {:jose_jwe_alg_ecdh_ss,
         {:jose_jwk, :undefined,
          {:jose_jwk_kty_okp_x25519,
           <<179, 61, 73, 48, 198, 172, 53, 18, 208, 125, 114, 36, 188, 180, 209, 104, 235, 189, 239, 196, 16, 187, 90, 232, 20, 172, 65, 60, 166, 93, 176, 47>>}, %{}},
         <<198, 100, 16, 8, 90, 61, 247, 207, 210, 91, 199, 119, 250, 128, 109, 47, 241, 127, 150, 64, 48, 67, 135, 17, 181, 59, 209, 18, 71, 145, 209, 149, 59, 48, 103, 120, 36, 88, 199, 195, 113, 164, 186, 229, 150, 225, 31, 92, 216, 34, 34, 220, 46, 62, 2, 143, 56, 78, 193, 165, 202, 192, 77, 213>>,
         <<147, 142, 45, 11, 95, 18, 145, 115, 4, 91, 50, 132, 8, 20, 96, 185, 173, 51, 103, 243, 11, 14, 254, 84, 227, 163, 28, 159, 38, 51, 143, 64>>,
         :undefined, :undefined, :undefined, :undefined}},
       enc: {:jose_jwe_enc_aes,
        {:jose_jwe_enc_aes, {:aes_gcm, 128}, 128, 16, 12, :undefined, :undefined,
         :undefined, :undefined}},
       zip: :undefined,
       fields: %{}
     }}

## box_encrypt_ecdh_ss(plain_text, v_static_public_key, u_static_secret_key)

ECDH-SS Key Agreement encryption of `plain_text` using `v_static_public_key`, `u_static_secret_key`, and a derived `jwe` based on the input key types.  See `box_encrypt_ecdh_ss/4`.

## box_encrypt_ecdh_ss(plain_text, jwe, v_static_public_key, u_static_secret_key)

ECDH-SS Key Agreement encryption of `plain_text` using `v_static_public_key`, `u_static_secret_key`, and the algorithms specified by the `jwe`.

## from(list)

Converts a binary or map into a `JOSE.JWK`.

    iex> JOSE.JWK.from(%{"k" => "", "kty" => "oct"})
    %JOSE.JWK{fields: %{}, keys: :undefined, kty: {:jose_jwk_kty_oct, ""}}
    iex> JOSE.JWK.from("{"k":"","kty":"oct"}")
    %JOSE.JWK{fields: %{}, keys: :undefined, kty: {:jose_jwk_kty_oct, ""}}

The `"kty"` field may be overridden with a custom module that implements the `:jose_jwk` and `:jose_jwk_kty` behaviours.

For example:

    iex> JOSE.JWK.from({%{ kty: MyCustomKey }, %{ "kty" => "custom" }})
    %JOSE.JWK{fields: %{}, keys: :undefined, kty: {MyCustomKey, :state}}

## from(password, list)

Decrypts an encrypted binary or map into a `JOSE.JWK` using the specified `password`.

    iex> JOSE.JWK.from("password", "eyJhbGciOiJQQkVTMi1IUzI1NitBMTI4S1ciLCJjdHkiOiJqd2sranNvbiIsImVuYyI6IkExMjhHQ00iLCJwMmMiOjQwOTYsInAycyI6Im5OQ1ZNQUktNTU5UVFtbWRFcnBsZFEifQ.Ucye69ii4dxd1ykNFlJyBVeA6xeNu4aV.2pZ4nBoxBjmdrneS.boqwdFZVNAFHk1M5P6kPYgBUgGwW32QuKzHuFA.wL9Hy6dcE_DPkUW9s5iwKA")
    {%JOSE.JWE{alg: {:jose_jwe_alg_pbes2,
       {:jose_jwe_alg_pbes2, :sha256, 128,
        <<80, 66, 69, 83, 50, 45, 72, 83, 50, 53, 54, 43, 65, 49, 50, 56, 75, 87, 0, 156, 208, 149, 48, 2, 62, 231, 159, 80, 66, 105, 157, 18, 186, 101, 117>>,
        4096}},
      enc: {:jose_jwe_enc_aes,
       {:jose_jwe_enc_aes, {:aes_gcm, 128}, 128, 16, 12, :undefined, :undefined,
        :undefined, :undefined}}, fields: %{"cty" => "jwk+json"}, zip: :undefined},
     %JOSE.JWK{fields: %{}, keys: :undefined, kty: {:jose_jwk_kty_oct, "secret"}}}

## from_binary(list)

Converts a binary into a `JOSE.JWK`.

## from_binary(password, list)

Decrypts an encrypted binary into a `JOSE.JWK` using `password`.  See `from/2`.

## from_der(list)

Converts a DER (Distinguished Encoding Rules)  binary into a `JOSE.JWK`.

## from_der(password, list)

Decrypts an encrypted DER (Distinguished Encoding Rules)  binary into a `JOSE.JWK` using `password`.

## from_der_file(file)

Reads file and calls `from_der/1` to convert into a `JOSE.JWK`.

## from_der_file(password, file)

Reads encrypted file and calls `from_der/2` to convert into a `JOSE.JWK` using `password`.

## from_file(file)

Reads file and calls `from_binary/1` to convert into a `JOSE.JWK`.

## from_file(password, file)

Reads encrypted file and calls `from_binary/2` to convert into a `JOSE.JWK` using `password`.  See `from/2`.

## from_firebase(any)

Converts Firebase certificate public keys into a map of `JOSE.JWK`.

## from_key(list)

Converts Erlang records for `:ECPrivateKey`, `:ECPublicKey`, `:RSAPrivateKey`, and `:RSAPublicKey` into a `JOSE.JWK`.

## from_map(list)

Converts a map into a `JOSE.JWK`.

## from_map(password, list)

Decrypts an encrypted map into a `JOSE.JWK` using `password`.  See `from/2`.

## from_oct(list)

Converts an arbitrary binary into a `JOSE.JWK` with `"kty"` of `"oct"`.

## from_oct(password, list)

Decrypts an encrypted arbitrary binary into a `JOSE.JWK` with `"kty"` of `"oct"` using `password`.  See `from/2`.

## from_oct_file(file)

Reads file and calls `from_oct/1` to convert into a `JOSE.JWK`.

## from_oct_file(password, file)

Reads encrypted file and calls `from_oct/2` to convert into a `JOSE.JWK` using `password`.  See `from/2`.

## from_okp(list)

Converts an octet key pair into a `JOSE.JWK` with `"kty"` of `"OKP"`.

## from_openssh_key(list)

Converts an openssh key into a `JOSE.JWK` with `"kty"` of `"OKP"`.

## from_openssh_key_file(file)

Reads file and calls `from_openssh_key/1` to convert into a `JOSE.JWK`.

## from_pem(list)

Converts a PEM (Privacy Enhanced Email) binary into a `JOSE.JWK`.

## from_pem(password, list)

Decrypts an encrypted PEM (Privacy Enhanced Email) binary into a `JOSE.JWK` using `password`.

## from_pem_file(file)

Reads file and calls `from_pem/1` to convert into a `JOSE.JWK`.

## from_pem_file(password, file)

Reads encrypted file and calls `from_pem/2` to convert into a `JOSE.JWK` using `password`.

## from_record(jose_jwk)

Converts a `:jose_jwk` record into a `JOSE.JWK`.

## generate_key(jwk)

Generates a new `JOSE.JWK` based on another `JOSE.JWK` or from initialization params provided.

Passing another `JOSE.JWK` results in different behavior depending on the `"kty"`:

  * `"EC"` - uses the same named curve to generate a new key
  * `"oct"` - uses the byte size to generate a new key
  * `"OKP"` - uses the same named curve to generate a new key
  * `"RSA"` - uses the same modulus and exponent sizes to generate a new key

The following initialization params may also be used:

  * `{:ec, "secp256k1", "P-256" | "P-384" | "P-521"}` - generates an `"EC"` key using the `"secp256k1"`, `"P-256"`, `"P-384"`, or `"P-521"` curves
  * `{:oct, bytes}` - generates an `"oct"` key made of a random `bytes` number of bytes
  * `{:okp, :Ed25519 | :Ed25519ph | :Ed448 | :Ed448ph | :X25519 | :X448}` - generates an `"OKP"` key using the specified EdDSA or ECDH edwards curve
  * `{:rsa, modulus_size} | {:rsa, modulus_size, exponent_size}` - generates an `"RSA"` key using the `modulus_size` and `exponent_size`

## merge(left, right)

Merges map on right into map on left.

## shared_secret(your_jwk, my_jwk)

Computes the shared secret between two keys.  Currently only works for `"EC"` keys and `"OKP"` keys with `"crv"` set to `"X25519"` or `"X448"`.

## sign(plain_text, jwk)

Signs the `plain_text` using the `jwk` and the default signer algorithm `jws` for the key type.  See `sign/3`.

## sign(plain_text, jws, jwk)

Signs the `plain_text` using the `jwk` and the algorithm specified by the `jws`.  See `JOSE.JWS.sign/3`.

## signer(list)

Returns a signer map for the key type.

## thumbprint(list)

Returns the unique thumbprint for a `JOSE.JWK` using the `:sha256` digest type.  See `thumbprint/2`.

## thumbprint(digest_type, list)

Returns the unique thumbprint for a `JOSE.JWK` using the `digest_type`.

    # let's define two different keys that will have the same thumbprint
    jwk1 = JOSE.JWK.from_oct("secret")
    jwk2 = JOSE.JWK.from(%{ "use" => "sig", "k" => "c2VjcmV0", "kty" => "oct" })

    iex> JOSE.JWK.thumbprint(jwk1)
    "DWBh0SEIAPYh1x5uvot4z3AhaikHkxNJa3Ada2fT-Cg"
    iex> JOSE.JWK.thumbprint(jwk2)
    "DWBh0SEIAPYh1x5uvot4z3AhaikHkxNJa3Ada2fT-Cg"
    iex> JOSE.JWK.thumbprint(:md5, jwk1)
    "Kldz8k5PQm7y1E3aNBlMiA"
    iex> JOSE.JWK.thumbprint(:md5, jwk2)
    "Kldz8k5PQm7y1E3aNBlMiA"

See JSON Web Key (JWK) Thumbprint [RFC 7638](https://tools.ietf.org/html/rfc7638) for more information.

## to_binary(list)

Converts a `JOSE.JWK` into a binary.

## to_binary(password, list)

Encrypts a `JOSE.JWK` into a binary using `password` and the default `jwe` for the key type.  See `to_binary/3`.

## to_binary(password, jwe, jwk)

Encrypts a `JOSE.JWK` into a binary using `password` and `jwe`.

## to_der(list)

Converts a `JOSE.JWK` into a DER (Distinguished Encoding Rules)  binary.

## to_der(password, list)

Encrypts a `JOSE.JWK` into a DER (Distinguished Encoding Rules)  encrypted binary using `password`.

## to_der_file(file, jwk)

Calls `to_der/1` on a `JOSE.JWK` and then writes the binary to file.

## to_der_file(password, file, jwk)

Calls `to_der/2` on a `JOSE.JWK` and then writes the encrypted binary to file.

## to_file(file, jwk)

Calls `to_binary/1` on a `JOSE.JWK` and then writes the binary to file.

## to_file(password, file, jwk)

Calls `to_binary/2` on a `JOSE.JWK` and then writes the encrypted binary to file.

## to_file(password, file, jwe, jwk)

Calls `to_binary/3` on a `JOSE.JWK` and then writes the encrypted binary to file.

## to_key(list)

Converts a `JOSE.JWK` into the raw key format.

## to_map(list)

Converts a `JOSE.JWK` into a map.

## to_map(password, list)

Encrypts a `JOSE.JWK` into a map using `password` and the default `jwe` for the key type.  See `to_map/3`.

## to_map(password, jwe, jwk)

Encrypts a `JOSE.JWK` into a map using `password` and `jwe`.

## to_oct(list)

Converts a `JOSE.JWK` into a raw binary octet.

## to_oct(password, list)

Encrypts a `JOSE.JWK` into a raw binary octet using `password` and the default `jwe` for the key type.  See `to_oct/3`.

## to_oct(password, jwe, jwk)

Encrypts a `JOSE.JWK` into a raw binary octet using `password` and `jwe`.

## to_oct_file(file, jwk)

Calls `to_oct/1` on a `JOSE.JWK` and then writes the binary to file.

## to_oct_file(password, file, jwk)

Calls `to_oct/2` on a `JOSE.JWK` and then writes the encrypted binary to file.

## to_oct_file(password, file, jwe, jwk)

Calls `to_oct/3` on a `JOSE.JWK` and then writes the encrypted binary to file.

## to_okp(list)

Converts a `JOSE.JWK` into an octet key pair.

## to_openssh_key(list)

Converts a `JOSE.JWK` into an OpenSSH key binary.

## to_openssh_key_file(file, jwk)

Calls `to_openssh_key/1` on a `JOSE.JWK` and then writes the binary to file.

## to_pem(list)

Converts a `JOSE.JWK` into a PEM (Privacy Enhanced Email) binary.

## to_pem(password, list)

Encrypts a `JOSE.JWK` into a PEM (Privacy Enhanced Email) encrypted binary using `password`.

## to_pem_file(file, jwk)

Calls `to_pem/1` on a `JOSE.JWK` and then writes the binary to file.

## to_pem_file(password, file, jwk)

Calls `to_pem/2` on a `JOSE.JWK` and then writes the encrypted binary to file.

## to_public(list)

Converts a private `JOSE.JWK` into a public `JOSE.JWK`.

    iex> jwk_rsa = JOSE.JWK.generate_key({:rsa, 256})
    %JOSE.JWK{fields: %{}, keys: :undefined,
     kty: {:jose_jwk_kty_rsa,
      {:RSAPrivateKey, :"two-prime",
       89657271283923333213688956979801646886488725937927826421780028977595670900943,
       65537,
       49624301670095289515744590467755999498582844809776145284365095264133428741569,
       336111124810514302695156165996294214367,
       266748895426976520545002702829665062929,
       329628611699439793965634256329704106687,
       266443630200356088742496100410997365601,
       145084675516165292189647528713269147163, :asn1_NOVALUE}}}
    iex> JOSE.JWK.to_public(jwk_rsa)
    %JOSE.JWK{fields: %{}, keys: :undefined,
     kty: {:jose_jwk_kty_rsa,
      {:RSAPublicKey,
       89657271283923333213688956979801646886488725937927826421780028977595670900943,
       65537}}}

## to_public_file(file, jwk)

Calls `to_public/1` and then `to_file/2` on a `JOSE.JWK`.

## to_public_key(list)

Calls `to_public/1` and then `to_key/1` on a `JOSE.JWK`.

## to_public_map(list)

Calls `to_public/1` and then `to_map/1` on a `JOSE.JWK`.

## to_record(list)

Converts a `JOSE.JWK` struct to a `:jose_jwk` record.

## to_thumbprint_map(list)

Converts a `JOSE.JWK` into a map that can be used by `thumbprint/1` and `thumbprint/2`.

## verifier(list)

Returns a verifier algorithm list for the key type.

## verify(signed, jwk)

Verifies the `signed` using the `jwk`.  See `JOSE.JWS.verify_strict/3`.

## verify_strict(signed, allow, jwk)

Verifies the `signed` using the `jwk` and whitelists the `"alg"` using `allow`.  See `JOSE.JWS.verify/2`.