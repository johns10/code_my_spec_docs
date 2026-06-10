# RustlerPrecompiled



## available_nifs/1

Returns URLs for NIFs based on its module name as a list of tuples: `[{lib_name, {url, headers}}]`.

The module name is the one that defined the NIF and this information
is stored in a metadata file.

## current_target_nifs/1

Returns the file URLs to be downloaded for current target as a list of tuples: `[{lib_name, {url, headers}}]`.

It is in the plural because a target may have some variants for it.
It receives the NIF module.

## target/3

Returns the target triple for download or compile and load.

This function is translating and adding more info to the system
architecture returned by Elixir/Erlang to one used by Rust.

The returned string has the following format:

    "nif-NIF_VERSION-ARCHITECTURE-VENDOR-OS-ABI"

## Examples

    iex> RustlerPrecompiled.target()
    {:ok, "nif-2.16-x86_64-unknown-linux-gnu"}

    iex> RustlerPrecompiled.target()
    {:ok, "nif-2.15-aarch64-apple-darwin"}