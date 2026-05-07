# Cloak.Crypto.Interface



## decrypt_one_time/4

Alias for `:crypto.crypto_one_time/5` with `opts[:encrypt]` set to `false`.

## decrypt_one_time_aead/6

Alias for `:crypto.crypto_one_time_aead/7` with `encFlag` set to `false`.

## encrypt_one_time/4

Alias for `:crypto.crypto_one_time/5` with `opts[:encrypt]` set to `true`.

## encrypt_one_time_aead/5

Alias for `:crypto.crypto_one_time_aead/7` with `encFlag` set to `true`.

## map_cipher/1

Converts a cipher name to a supported cipher name, depending on the crypto library.

## strong_rand_bytes/1

Alias for `:crypto.strong_rand_bytes/1`.