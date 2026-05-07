# Phoenix.Endpoint

Defines a Phoenix endpoint.

The endpoint is the boundary where all requests to your
web application start. It is also the interface your
application provides to the underlying web servers.

Overall, an endpoint has three responsibilities:

  * to provide a wrapper for starting and stopping the
    endpoint as part of a supervision tree

  * to define an initial plug pipeline for requests
    to pass through

  * to host web specific configuration for your
    application

## Endpoints

An endpoint is simply a module defined with the help
of `Phoenix.Endpoint`. If you have used the `mix phx.new`
generator, an endpoint was automatically generated as
part of your application:

    defmodule YourAppWeb.Endpoint do
      use Phoenix.Endpoint, otp_app: :your_app

      # plug ...
      # plug ...

      plug YourApp.Router
    end

Endpoints must be explicitly started as part of your application
supervision tree. Endpoints are added by default
to the supervision tree in generated applications. Endpoints can be
added to the supervision tree as follows:

    children = [
      YourAppWeb.Endpoint
    ]

## Endpoint configuration

All endpoints are configured in your application environment.
For example:

    config :your_app, YourAppWeb.Endpoint,
      secret_key_base: "kjoy3o1zeidquwy1398juxzldjlksahdk3"

Endpoint configuration is split into two categories. Compile-time
configuration means the configuration is read during compilation
and changing it at runtime has no effect. The compile-time
configuration is mostly related to error handling.

Runtime configuration, instead, is accessed during or
after your application is started and can be read through the
`c:config/2` function:

    YourAppWeb.Endpoint.config(:port)
    YourAppWeb.Endpoint.config(:some_config, :default_value)

### Compile-time configuration

Compile-time configuration may be set on `config/dev.exs`, `config/prod.exs`
and so on, but has no effect on `config/runtime.exs`:

  * `:code_reloader` - when `true`, enables code reloading functionality.
    For the list of code reloader configuration options see
    `Phoenix.CodeReloader.reload/1`. Keep in mind code reloading is
    based on the file-system, therefore it is not possible to run two
    instances of the same app at the same time with code reloading in
    development, as they will race each other and only one will effectively
    recompile the files. In such cases, tweak your config files so code
    reloading is enabled in only one of the apps or set the `MIX_BUILD_PATH`
    environment variable to give them distinct build directories

  * `:debug_errors` - when `true`, uses `Plug.Debugger` functionality for
    debugging failures in the application. Recommended to be set to `true`
    only in development as it allows listing of the application source
    code during debugging. Defaults to `false`

  * `:force_ssl` - ensures no data is ever sent via HTTP, always redirecting
    to HTTPS. It expects a list of options which are forwarded to `Plug.SSL`.
    By default it sets the "strict-transport-security" header in HTTPS requests,
    forcing browsers to always use HTTPS. If an unsafe request (HTTP) is sent,
    it redirects to the HTTPS version using the `:host` specified in the `:url`
    configuration. To dynamically redirect to the `host` of the current request,
    set `:host` in the `:force_ssl` configuration to `nil`

### Runtime configuration

The configuration below may be set on `config/dev.exs`, `config/prod.exs`
and so on, as well as on `config/runtime.exs`. Typically, if you need to
configure them with system environment variables, you set them in
`config/runtime.exs`. These options may also be set when starting the
endpoint in your supervision tree, such as `{MyApp.Endpoint, options}`.

  * `:adapter` - which webserver adapter to use for serving web requests.
    See the "Adapter configuration" section below

  * `:cache_static_manifest` - a path to a json manifest file that contains
    static files and their digested version. This is typically set to
    "priv/static/cache_manifest.json" which is the file automatically generated
    by `mix phx.digest`. It can be either: a string containing a file system path
    or a tuple containing the application name and the path within that application.

  * `:cache_static_manifest_latest` - a map of the static files pointing to their
    digest version. This is automatically loaded from `cache_static_manifest` on
    boot. However, if you have your own static handling mechanism, you may want to
    set this value explicitly. This is used by projects such as `LiveView` to
    detect if the client is running on the latest version of all assets.

  * `:cache_manifest_skip_vsn` - when true, skips the appended query string
    "?vsn=d" when generating paths to static assets. This query string is used
    by `Plug.Static` to set long expiry dates, therefore, you should set this
    option to true only if you are not using `Plug.Static` to serve assets,
    for example, if you are using a CDN. If you are setting this option, you
    should also consider passing `--no-vsn` to `mix phx.digest`. Defaults to
    `false`.

  * `:check_origin` - configure the default `:check_origin` setting for
    transports. See `socket/3` for options. Defaults to `true`.

  * `:secret_key_base` - a secret key used as a base to generate secrets
    for encrypting and signing data. For example, cookies and tokens
    are signed by default, but they may also be encrypted if desired.
    Defaults to `nil` as it must be set per application

  * `:server` - when `true`, starts the web server when the endpoint
    supervision tree starts. Defaults to `false`. The `mix phx.server`
    task automatically sets this to `true`

  * `:url` - configuration for generating URLs throughout the app.
    Accepts the `:host`, `:scheme`, `:path` and `:port` options. All
    keys except `:path` can be changed at runtime. Defaults to:

        [host: "localhost", path: "/"]

    The `:port` option requires either an integer or string. The `:host`
    option requires a string.

    The `:scheme` option accepts `"http"` and `"https"` values. Default value
    is inferred from top level `:http` or `:https` option. It is useful
    when hosting Phoenix behind a load balancer or reverse proxy and
    terminating SSL there.

    The `:path` option can be used to override root path. Useful when hosting
    Phoenix behind a reverse proxy with URL rewrite rules

  * `:static_url` - configuration for generating URLs for static files.
    It will fallback to `url` if no option is provided. Accepts the same
    options as `url`

  * `:watchers` - a set of watchers to run alongside your server. It
    expects a list of tuples containing the executable and its arguments.
    Watchers are guaranteed to run in the application directory, but only
    when the server is enabled (unless `:force_watchers` configuration is
    set to `true`). For example, the watcher below will run the "watch" mode
    of the webpack build tool when the server starts. You can configure it
    to whatever build tool or command you want:

        [
          node: [
            "node_modules/webpack/bin/webpack.js",
            "--mode",
            "development",
            "--watch",
            "--watch-options-stdin"
          ]
        ]

    The `:cd` and `:env` options can be given at the end of the list to customize
    the watcher:

        [node: [..., cd: "assets", env: [{"TAILWIND_MODE", "watch"}]]]

    A watcher can also be a module-function-args tuple that will be invoked accordingly:

        [another: {Mod, :fun, [arg1, arg2]}]

    When `false`, watchers can be disabled.

  * `:force_watchers` - when `true`, forces your watchers to start
    even when the `:server` option is set to `false`.

  * `:live_reload` - configuration for the live reload option.
    Configuration requires a `:patterns` option which should be a list of
    file patterns to watch. When these files change, it will trigger a reload.

        live_reload: [
          url: "ws://localhost:4000",
          patterns: [
            ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
            ~r"lib/app_web/(live|views)/.*(ex)$",
            ~r"lib/app_web/templates/.*(eex)$"
          ]
        ]

  * `:pubsub_server` - the name of the pubsub server to use in channels
    and via the Endpoint broadcast functions. The PubSub server is typically
    started in your supervision tree.

  * `:render_errors` - responsible for rendering templates whenever there
    is a failure in the application. For example, if the application crashes
    with a 500 error during a HTML request, `render("500.html", assigns)`
    will be called in the view given to `:render_errors`.
    A `:formats` list can be provided to specify a module per format to handle
    error rendering. Example:

        [formats: [html: MyApp.ErrorHTML], layout: false, log: :debug]

  * `:log_access_url` - log the access url once the server boots

Note that you can also store your own configurations in the Phoenix.Endpoint.
For example, [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view) expects
its own configuration under the `:live_view` key. In such cases, you should
consult the documentation of the respective projects.

### Adapter configuration

Phoenix allows you to choose which webserver adapter to use. Newly generated
applications created via the `phx.new` Mix task use the
[`Bandit`](https://github.com/mtrudel/bandit) webserver via the
`Bandit.PhoenixAdapter` adapter. If not otherwise specified via the `adapter`
option Phoenix will fall back to the `Phoenix.Endpoint.Cowboy2Adapter` for
backwards compatibility with applications generated prior to Phoenix 1.7.8.

Both adapters can be configured in a similar manner using the following two
top-level options:

  * `:http` - the configuration for the HTTP server. It accepts all options
    as defined by either [`Bandit`](https://hexdocs.pm/bandit/Bandit.html#t:options/0)
    or [`Plug.Cowboy`](https://hexdocs.pm/plug_cowboy/) depending on your
    choice of adapter. Defaults to `false`

  * `:https` - the configuration for the HTTPS server. It accepts all options
    as defined by either [`Bandit`](https://hexdocs.pm/bandit/Bandit.html#t:options/0)
    or [`Plug.Cowboy`](https://hexdocs.pm/plug_cowboy/) depending on your
    choice of adapter. Defaults to `false`

In addition, the connection draining can be configured for the Cowboy webserver via the following
top-level option (this is not required for Bandit as it has connection draining built-in):

  * `:drainer` - a drainer process waits for any on-going request to finish
    during application shutdown. It accepts the `:shutdown` and
    `:check_interval` options as defined by `Plug.Cowboy.Drainer`.
    Note the draining does not terminate any existing connection, it simply
    waits for them to finish. Socket connections run their own drainer
    before this one is invoked. That's because sockets are stateful and
    can be gracefully notified, which allows us to stagger them over a
    longer period of time. See the documentation for `socket/3` for more
    information

## Endpoint API

In the previous section, we have used the `c:config/2` function that is
automatically generated in your endpoint. Here's a list of all the functions
that are automatically defined in your endpoint:

  * for handling paths and URLs: `c:struct_url/0`, `c:url/0`, `c:path/1`,
    `c:static_url/0`,`c:static_path/1`, and `c:static_integrity/1`

  * for gathering runtime information about the address and port the
    endpoint is running on: `c:server_info/1`

  * for broadcasting to channels: `c:broadcast/3`, `c:broadcast!/3`,
    `c:broadcast_from/4`, `c:broadcast_from!/4`, `c:local_broadcast/3`,
    and `c:local_broadcast_from/4`

  * for configuration: `c:start_link/1`, `c:config/2`, and `c:config_change/2`

  * as required by the `Plug` behaviour: `c:Plug.init/1` and `c:Plug.call/2`

## server?(otp_app, endpoint)

Checks if Endpoint's web server has been configured to start.

  * `otp_app` - The OTP app running the endpoint, for example `:my_app`
  * `endpoint` - The endpoint module, for example `MyAppWeb.Endpoint`

## Examples

    iex> Phoenix.Endpoint.server?(:my_app, MyAppWeb.Endpoint)
    true

## socket(path, module, opts \\ [])

Defines a websocket/longpoll mount-point for a `socket`.

It expects a `path`, a `socket` module, and a set of options.
The socket module is typically defined with `Phoenix.Socket`.

Both websocket and longpolling connections are supported out
of the box.

## Options

  * `:websocket` - controls the websocket configuration.
    Defaults to `true`. May be false or a keyword list
    of options. See ["Common configuration"](#socket/3-common-configuration)
    and ["WebSocket configuration"](#socket/3-websocket-configuration)
    for the whole list

  * `:longpoll` - controls the longpoll configuration.
    Defaults to `false`. May be true or a keyword list
    of options. See ["Common configuration"](#socket/3-common-configuration)
    and ["Longpoll configuration"](#socket/3-longpoll-configuration)
    for the whole list

  * `:drainer` - a keyword list or a custom MFA function returning a keyword list, for example:

        {MyAppWeb.Socket, :drainer_configuration, []}

    configuring how to drain sockets on application shutdown.
    The goal is to notify all channels (and
    LiveViews) clients to reconnect. The supported options are:

    * `:batch_size` - How many clients to notify at once in a given batch.
      Defaults to 10000.
    * `:batch_interval` - The amount of time in milliseconds given for a
      batch to terminate. Defaults to 2000ms.
    * `:shutdown` - The maximum amount of time in milliseconds allowed
      to drain all batches. Defaults to 30000ms.
    * `:log` - the log level for drain actions. Defaults the `:log` option
      passed to `use Phoenix.Socket` or `:info`. Set it to `false` to disable logging.

    For example, if you have 150k connections, the default values will
    split them into 15 batches of 10k connections. Each batch takes
    2000ms before the next batch starts. In this case, we will do everything
    right under the maximum shutdown time of 30000ms. Therefore, as
    you increase the number of connections, remember to adjust the shutdown
    accordingly. Finally, after the socket drainer runs, the lower level
    HTTP/HTTPS connection drainer will still run, and apply to all connections.
    Set it to `false` to disable draining.

  * `auth_token` - a boolean that enables the use of the channels client's auth_token option.
    The exact token exchange mechanism depends on the transport:

      * the websocket transport, this enables a token to be passed through the `Sec-WebSocket-Protocol` header.
      * the longpoll transport, this allows the token to be passed through the `Authorization` header.

    The token is available in the `connect_info` as `:auth_token`.

    Custom transports might implement their own mechanism.

You can also pass the options below on `use Phoenix.Socket`.
The values specified here override the value in `use Phoenix.Socket`.

## Examples

    socket "/ws", MyApp.UserSocket

    socket "/ws/admin", MyApp.AdminUserSocket,
      longpoll: true,
      websocket: [compress: true]

## Path params

It is possible to include variables in the path, these will be
available in the `params` that are passed to the socket.

    socket "/ws/:user_id", MyApp.UserSocket,
      websocket: [path: "/project/:project_id"]

## Common configuration

The configuration below can be given to both `:websocket` and
`:longpoll` keys:

  * `:path` - the path to use for the transport. Will default
     to the transport name ("/websocket" or "/longpoll")

  * `:serializer` - a list of serializers for messages. See
    `Phoenix.Socket` for more information

  * `:transport_log` - if the transport layer itself should log and,
    if so, the level

  * `:check_origin` - if the transport should check the origin of requests when
    the `origin` header is present. May be `true`, `false`, a list of URIs that
    are allowed, or a function provided as MFA tuple. Defaults to `:check_origin`
    setting at endpoint configuration.

    If `true`, the header is checked against `:host` in `YourAppWeb.Endpoint.config(:url)[:host]`.

    If `false` and you do not validate the session in your socket, your app
    is vulnerable to Cross-Site WebSocket Hijacking (CSWSH) attacks.
    Only use in development, when the host is truly unknown or when
    serving clients that do not send the `origin` header, such as mobile apps.

    You can also specify a list of explicitly allowed origins. Each origin may include
    scheme, host, and port. Wildcards are supported.

        check_origin: [
          "https://example.com",
          "//another.com:888",
          "//*.other.com"
        ]

    Or to accept any origin matching the request connection's host, port, and scheme:

        check_origin: :conn

    Or a custom MFA function:

        check_origin: {MyAppWeb.Auth, :my_check_origin?, []}

    The MFA is invoked with the request `%URI{}` as the first argument,
    followed by arguments in the MFA list, and must return a boolean.

  * `:check_csrf` - if the transport should perform CSRF check. To avoid
    "Cross-Site WebSocket Hijacking", you must have at least one of
    `check_origin` and `check_csrf` enabled. If you set both to `false`,
    Phoenix will raise, but it is still possible to disable both by passing
    a custom MFA to `check_origin`. In such cases, it is your responsibility
    to ensure at least one of them is enabled. Defaults to `true`

  * `:code_reloader` - enable or disable the code reloader. Defaults to your
    endpoint configuration

  * `:connect_info` - a list of keys that represent data to be copied from
    the transport to be made available in the user socket `connect/3` callback.
    See the "Connect info" subsection for valid keys

### Connect info

The valid keys are:

  * `:peer_data` - the result of `Plug.Conn.get_peer_data/1`

  * `:trace_context_headers` - a list of all trace context headers. Supported
    headers are defined by the [W3C Trace Context Specification](https://www.w3.org/TR/trace-context-1/).
    These headers are necessary for libraries such as [OpenTelemetry](https://opentelemetry.io/)
    to extract trace propagation information to know this request is part of a
    larger trace in progress.

  * `:x_headers` - all request headers that have an "x-" prefix

  * `:uri` - a `%URI{}` with information from the conn

  * `:user_agent` - the value of the "user-agent" request header

  * `{:session, session_config}` - the session information from `Plug.Conn`.
    The `session_config` is typically an exact copy of the arguments given
    to `Plug.Session`. In order to validate the session, the "_csrf_token"
    must be given as request parameter when connecting the socket with the
    value of `URI.encode_www_form(Plug.CSRFProtection.get_csrf_token())`.
    The CSRF token request parameter can be modified via the `:csrf_token_key`
    option.

    Additionally, `session_config` may be a MFA, such as
    `{MyAppWeb.Auth, :get_session_config, []}`, to allow loading config in
    runtime.

Arbitrary keywords may also appear following the above valid keys, which
is useful for passing custom connection information to the socket.

For example:

```
  socket "/socket", AppWeb.UserSocket,
      websocket: [
        connect_info: [:peer_data, :trace_context_headers, :x_headers, :uri, session: [store: :cookie]]
      ]
```

With arbitrary keywords:

```
  socket "/socket", AppWeb.UserSocket,
      websocket: [
        connect_info: [:uri, custom_value: "abcdef"]
      ]
```

> #### Where are my headers? {: .tip}
>
> Phoenix only gives you limited access to the connection headers for security
> reasons. WebSockets are cross-domain, which means that, when a user "John Doe"
> visits a malicious website, the malicious website can open up a WebSocket
> connection to your application, and the browser will gladly submit John Doe's
> authentication/cookie information. If you were to accept this information as is,
> the malicious website would have full control of a WebSocket connection to your
> application, authenticated on John Doe's behalf.
>
> To safe-guard your application, Phoenix limits and validates the connection
> information your socket can access. This means your application is safe from
> these attacks, but you can't access cookies and other headers in your socket.
> You may access the session stored in the connection via the `:connect_info`
> option, provided you also pass a csrf token when connecting over WebSocket.

## Websocket configuration

The following configuration applies only to `:websocket`.

  * `:timeout` - the timeout for keeping websocket connections
    open after it last received data, defaults to 60_000ms

  * `:max_frame_size` - the maximum allowed frame size in bytes,
    defaults to "infinity"

  * `:fullsweep_after` - the maximum number of garbage collections
    before forcing a fullsweep for the socket process. You can set
    it to `0` to force more frequent cleanups of your websocket
    transport processes. Setting this option requires Erlang/OTP 24

  * `:compress` - whether to enable per message compression on
    all data frames, defaults to false

  * `:subprotocols` - a list of supported websocket subprotocols.
    Used for handshake `Sec-WebSocket-Protocol` response header, defaults to nil.

    For example:

        subprotocols: ["sip", "mqtt"]

  * `:error_handler` - custom error handler for connection errors.
    If `c:Phoenix.Socket.connect/3` returns an `{:error, reason}` tuple,
    the error handler will be called with the error reason. For WebSockets,
    the error handler must be a MFA tuple that receives a `Plug.Conn`, the
    error reason, and returns a `Plug.Conn` with a response. For example:

        socket "/socket", MySocket,
            websocket: [
              error_handler: {MySocket, :handle_error, []}
            ]

    and a `{:error, :rate_limit}` return may be handled on `MySocket` as:

        def handle_error(conn, :rate_limit), do: Plug.Conn.send_resp(conn, 429, "Too many requests")

## Longpoll configuration

The following configuration applies only to `:longpoll`:

  * `:window_ms` - how long the client can wait for new messages
    in its poll request in milliseconds (ms). Defaults to `10_000`.

  * `:pubsub_timeout_ms` - how long a request can wait for the
    pubsub layer to respond in milliseconds (ms). Defaults to `2000`.

  * `:crypto` - options for verifying and signing the token, accepted
    by `Phoenix.Token`. By default tokens are valid for 2 weeks

## broadcast/3

Broadcasts a `msg` as `event` in the given `topic` to all nodes.

## broadcast!/3

Broadcasts a `msg` as `event` in the given `topic` to all nodes.

Raises in case of failures.

## broadcast_from/4

Broadcasts a `msg` from the given `from` as `event` in the given `topic` to all nodes.

## broadcast_from!/4

Broadcasts a `msg` from the given `from` as `event` in the given `topic` to all nodes.

Raises in case of failures.

## config/2

Access the endpoint configuration given by key.

## config_change/2

Reload the endpoint configuration on application upgrades.

## host/0

Returns the host from the :url configuration.

## local_broadcast/3

Broadcasts a `msg` as `event` in the given `topic` within the current node.

## local_broadcast_from/4

Broadcasts a `msg` from the given `from` as `event` in the given `topic` within the current node.

## path/1

Generates the path information when routing to this endpoint.

## script_name/0

Returns the script name from the :url configuration.

## server_info/1

Returns the address and port that the server is running on

## start_link/1

Starts the endpoint supervision tree.

Starts endpoint's configuration cache and possibly the servers for
handling requests.

## static_integrity/1

Generates an integrity hash to a static file in `priv/static`.

## static_lookup/1

Generates a two item tuple containing the `static_path` and `static_integrity`.

## static_path/1

Generates a route to a static file in `priv/static`.

## static_url/0

Generates the static URL without any path information.

## struct_url/0

Generates the endpoint base URL, but as a `URI` struct.

## subscribe/2

Subscribes the caller to the given topic.

See `Phoenix.PubSub.subscribe/3` for options.

## unsubscribe/1

Unsubscribes the caller from the given topic.

## url/0

Generates the endpoint base URL without any path information.