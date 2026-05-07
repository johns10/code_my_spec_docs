# Mix.Tasks.Phx.Gen.Cert

Generates a self-signed certificate for HTTPS testing.

    $ mix phx.gen.cert
    $ mix phx.gen.cert my-app my-app.local my-app.internal.example.com

Creates a private key and a self-signed certificate in PEM format. These
files can be referenced in the `certfile` and `keyfile` parameters of an
HTTPS Endpoint.

WARNING: only use the generated certificate for testing in a closed network
environment, such as running a development server on `localhost`.
For production, staging, or testing servers on the public internet, obtain a
proper certificate, for example from [Let's Encrypt](https://letsencrypt.org).


## Arguments

The list of hostnames, if none are specified, defaults to:

  * localhost

Other (optional) arguments:

  * `--output` (`-o`): the path and base filename for the certificate and
    key (default: priv/cert/selfsigned)
  * `--name` (`-n`): the Common Name value in certificate's subject
    (default: "Self-signed test certificate")

Requires OTP 21.3 or later.