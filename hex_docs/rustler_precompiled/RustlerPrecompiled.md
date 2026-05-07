# RustlerPrecompiled

Download and use precompiled NIFs safely with checksums.

Rustler Precompiled is a tool for library maintainers that rely on Rustler.
It helps by removing the need to have the Rust compiler installed in the
user's machine.

Check the [Precompilation Guide](PRECOMPILATION_GUIDE.md) for details.

## Example

    defmodule MyApp.MyNative do
      use RustlerPrecompiled,
        otp_app: :my_app,
        crate: "my_app_nif",
        base_url: "https://github.com/me/my_project/releases/download/v0.1.0",
        version: "0.1.0"
    end

## Options

  * `:otp_app` - The OTP app name that the dynamic library will be loaded from.

  * `:crate` - The name of Rust crate if different from the `:otp_app`. This is optional.

  * `:base_url` - Location where to find the NIFs from. This should be one of the following:

    * A URL to a directory containing the NIFs. The name of the NIF will be appended to it
      and a GET request will be made. Works well with public GitHub releases.

    * A tuple of `{URL, headers}`. The headers should be a list of key-value pairs.
      This is useful when the NIFs are hosted in a private server.

    * A tuple of `{module, function}` where the `function` is an atom representing the function
      name in that module. It's expected a function of arity 1, where the NIF file name is given,
      and it should return a URL or a tuple of `{URL, headers}`.
      This should be used for all cases not covered by the above.
      For example when multiple requests have to be made, like when using a private GitHub release
      through the GitHub API, or when the URLs don't resemble a simple directory.

  * `:version` - The version of precompiled assets (it is part of the NIF filename).

  * `:force_build` - Force the build with `Rustler`. This is `false` by default, but
    if your `:version` is a pre-release (like "2.1.0-dev"), this option will always
    be set `true`.
    You can also configure this option by setting an application env like this:

        config :rustler_precompiled, :force_build, your_otp_app: true

    It is important to add the ":rustler" package to your dependencies in order to force
    the build. To do that, just add it to your `mix.exs` file:

        {:rustler, ">= 0.0.0", optional: true}

    In case you want to force the build for all packages using RustlerPrecompiled, you
    can set the application config `:force_build_all`, or the env var
    `RUSTLER_PRECOMPILED_FORCE_BUILD_ALL` (see details below):

        config :rustler_precompiled, force_build_all: true

  * `:targets` - A list of targets [supported by
    Rust](https://doc.rust-lang.org/rustc/platform-support.html) for which
    precompiled assets are available. By default the following targets are
    configured:

      - `aarch64-apple-darwin`
    - `aarch64-unknown-linux-gnu`
    - `aarch64-unknown-linux-musl`
    - `arm-unknown-linux-gnueabihf`
    - `riscv64gc-unknown-linux-gnu`
    - `x86_64-apple-darwin`
    - `x86_64-pc-windows-gnu`
    - `x86_64-pc-windows-msvc`
    - `x86_64-unknown-linux-gnu`
    - `x86_64-unknown-linux-musl`

  * `:nif_versions` - A list of OTP NIF versions for which precompiled assets are
    available. A NIF version is usually compatible with two OTP minor versions, and an older
    NIF is usually compatible with newer OTPs. The available versions are the following:

    * `2.14` - for OTP 21 and above.
    * `2.15` - for OTP 22 and above.
    * `2.16` - for OTP 24 and above.
    * `2.17` - for OTP 26 and above.

    By default the following NIF versions are configured:

      - `2.15`

    Check the compatibiliy table between Elixir and OTP in:
    https://hexdocs.pm/elixir/compatibility-and-deprecations.html#compatibility-between-elixir-and-erlang-otp

  * `:max_retries` - The maximum of retries before giving up. Defaults to `3`.
    Retries can be disabled with `0`.

  * `:variants` - A map with alternative versions of a given target. This is useful to
    support specific versions of dependencies, such as an old glibc version, or to support
    restrict CPU features, like AVX on x86_64.

    The order of variants matters, because the first one that returns `true` is going to be
    selected. Example:

        %{"x86_64-unknown-linux-gnu" => [old_glibc: fn _config -> has_old_glibc?() end]}

In case "force build" is used, all options except the ones use by RustlerPrecompiled
are going to be passed down to `Rustler`.
So if you need to configure the build, check the `Rustler` options.

## Environment variables

This project reads some system environment variables. They are all optional, but they
can change the behaviour of this library at **compile time** of your project.

They are:

  * `HTTP_PROXY` or `http_proxy` - Sets the HTTP proxy configuration.

  * `HTTPS_PROXY` or `https_proxy` - Sets the HTTPS proxy configuration.

  * `HEX_CACERTS_PATH` - Sets the path for a custom CA certificates file.
    If unset, defaults to `CAStore.file_path/0`.

  * `MIX_XDG` - If present, sets the OS as `:linux` for the `:filename.basedir/3` when getting
    an user cache dir.

  * `TARGET_ARCH` - The CPU target architecture. This is useful for when building your Nerves
    project, where your host CPU is different from your target CPU.

    Note that Nerves sets this value automatically when building your project.

    Examples: `arm`, `aarch64`, `x86_64`, `riscv64`.

  * `TARGET_ABI` - The target ABI (e.g., `gnueabihf`, `musl`). This is set by Nerves as well.

  * `TARGET_VENDOR` - The target vendor (e.g., `unknown`, `apple`, `pc`). This is **not** set by Nerves.
    If any of the `TARGET_` env vars is set, but `TARGET_VENDOR` is empty, then we change the
    target vendor to `unknown` that is the default value for Linux systems.

  * `TARGET_OS` - The target operational system. This is always `linux` for Nerves.

  * `RUSTLER_PRECOMPILED_GLOBAL_CACHE_PATH` - The global cache path directory. If set, it will ignore
    the default cache path resolution, thus ignoring `MIX_XDG`, and will try to fetch the artifacts
    from that path. In case the desired artifact is not found, a download is going to start.

    This variable is important for systems that cannot perform a download at compile time, like inside
    NixOS. It will require people to previously download the artifacts to that path.

  * `RUSTLER_PRECOMPILED_FORCE_BUILD_ALL` - If set to "1" or "true", it will override the `:force_build`
    configuration for all packages, and will force the build for them all.
    You can set the `:force_build_all` configuration to `true` to have the same effect.

Note that all packages using `RustlerPrecompiled` will be affected by these environment variables.

For more details about Nerves env vars, see https://hexdocs.pm/nerves/environment-variables.html

## available_nifs(nif_module)

Returns URLs for NIFs based on its module name as a list of tuples: `[{lib_name, {url, headers}}]`.

The module name is the one that defined the NIF and this information
is stored in a metadata file.

## current_target_nifs(nif_module)

Returns the file URLs to be downloaded for current target as a list of tuples: `[{lib_name, {url, headers}}]`.

It is in the plural because a target may have some variants for it.
It receives the NIF module.

## target(config \\ target_config(), available_targets \\ Config.default_targets(), available_nif_versions \\ Config.available_nif_versions())

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