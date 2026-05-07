# Plug.Crypto.MessageEncryptor

`MessageEncryptor` is a simple way to encrypt values which get stored
somewhere you don't trust.

The encrypted key, initialization vector, cipher text, and cipher tag
are base64url encoded and returned to you.

This can be used in situations similar to the `Plug.Crypto.MessageVerifier`,
but where you don't want users to be able to determine the value of the payload.

The current algorithm used is XChaCha20-Poly1305.

## Example

    iex> secret_key_base = "072d1e0157c008193fe48a670cce031faa4e..."
    ...> encrypted_cookie_salt = "encrypted cookie"
    ...> secret = KeyGenerator.generate(secret_key_base, encrypted_cookie_salt)
    ...>
    ...> data = "José"
    ...> encrypted = MessageEncryptor.encrypt(data, secret, "UNUSED")
    ...> MessageEncryptor.decrypt(encrypted, secret, "UNUSED")
    {:ok, "José"}

## decrypt(encrypted, aad \\ "A128GCM", secret, sign_secret)

Decrypts a message using authenticated encryption.

## encrypt(message, aad \\ "A128GCM", secret, sign_secret)

Encrypts a message using authenticated encryption.

The `sign_secret` is currently only used on decryption
for backwards compatibility.

A custom authentication message can be provided.
It defaults to "A128GCM" for backwards compatibility.