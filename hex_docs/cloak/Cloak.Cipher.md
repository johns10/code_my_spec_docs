# Cloak.Cipher

A behaviour for encryption/decryption modules. You can rely on this behaviour
to create your own Cloak-compatible cipher modules.

## Example

We will create a cipher that simply prepends `"Hello, "` to any given
plaintext on encryption, and removes the prefix on decryption.

First, define your own cipher module, and specify the `Cloak.Cipher`
behaviour.

    defmodule MyApp.PrefixCipher do
      @behaviour Cloak.Cipher
    end

Add some configuration to your vault for this new cipher:

    config :my_app, MyApp.Vault,
      ciphers: [
        prefix: {MyApp.PrefixCipher, prefix: "Hello, "}
      ]

The keyword list containing the `:prefix` will be passed in as `opts`
to our cipher callbacks. You should specify any options your cipher will
need for encryption/decryption here, such as the key.

Next, define the `can_decrypt?/2` callback:

    @impl true
    def can_decrypt?(ciphertext, opts) do
      String.starts_with?(ciphertext, opts[:prefix])
    end

If the ciphertext starts with `"Hello, "`, we know it was encrypted with this
cipher and we can proceed. Finally, define the `encrypt` and `decrypt`
functions:

    @impl true
    def encrypt(plaintext, opts) do
      opts[:prefix] <> plaintext
    end

    @impl true
    def decrypt(ciphertext, opts) do
      String.replace(ciphertext, opts[:prefix], "")
    end

You can now use your cipher with your vault!

    MyApp.Vault.encrypt!("World!", :prefix)
    # => "Hello, World!"

    MyApp.Vault.decrypt!("Hello, World!")
    # => "World!"

## can_decrypt?/2

Determines if a given ciphertext can be decrypted by this cipher. Options
are derived from the cipher configuration. See `encrypt/2`.

## decrypt/2

Decrypt a value, using the given opts. Options are derived from the cipher
configuration. See `encrypt/2`.

## encrypt/2

Encrypt a value, using the given keyword list of options. These options
derive from the cipher configuration, like so:

    config :my_app, MyApp.Vault,
      ciphers: [
        default: {Cloak.Ciphers.AES.GCM, tag: "AES.GCM.V1", key: <<1, 0, ...>>}
      ]

The above configuration will result in the following `opts` being passed
to this function:

    [tag: "AES.GCM.V1", key: <<1, 0, ...>>]

Your implementation **must** include any information it will need for
decryption in the generated ciphertext.