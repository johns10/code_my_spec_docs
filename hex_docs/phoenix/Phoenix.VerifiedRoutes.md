# Phoenix.VerifiedRoutes

Provides route generation with compile-time verification.

Use of the `sigil_p` macro allows paths and URLs throughout your
application to be compile-time verified against your Phoenix router(s).
For example, the following path and URL usages:

    ~H"""
    <a href={~p"/sessions/new"}>Log in</a>
    """

    redirect(to: url(~p"/posts/#{post}"))

Will be verified against your standard `Phoenix.Router` definitions:

    get "/posts/:post_id", PostController, :show
    post "/sessions/new", SessionController, :create

Unmatched routes will issue compiler warnings:

```console
warning: no route path for AppWeb.Router matches "/postz/#{post}"
  lib/app_web/controllers/post_controller.ex:100: AppWeb.PostController.show/2
```

Additionally, interpolated ~p values are encoded via the `Phoenix.Param` protocol.
For example, a `%Post{}` struct in your application may derive the `Phoenix.Param`
protocol to generate slug-based paths rather than ID based ones. This allows you to
use `~p"/posts/#{post}"` rather than `~p"/posts/#{post.slug}"` throughout your
application. See the `Phoenix.Param` documentation for more details.

Finally, query strings are also supported in verified routes, either in traditional form:

    ~p"/posts?page=#{page}"

Or as a keyword list or map of values:

    params = %{page: 1, direction: "asc"}
    ~p"/posts?#{params}"

Like path segments, query strings params are proper URL encoded and may be interpolated
directly into the ~p string.

To ease url comparisons during tests (e.g. when using `assert_redirect/3`) query params
will be sorted. This is controlled by the `phoenix: [sort_verified_routes_query_params: true]`
configuration option.

## What about named routes?

Many web frameworks, and early versions of Phoenix, provided a feature called "named routes".
The idea is that, when you define routes in your web applications, you could give them names
too. In Phoenix that was done as follows:

    get "/login", SessionController, :create, as: :login

And now you could generate the route using the `login_path` function.

Named routes exist to avoid hardcoding routes in your templates, if you wrote `<a href="/login">`
and then changed your router, the link would point to a page that no longer exist. By using
`login_path`, we make sure it always points to a valid URL in our router. However, named routes
come with the downsides of indirection: when you look at the code, it is not immediately clear
which URL will be generated. Furthermore, if you have an existing URL and you want to add it
to a template, you need to do a reverse lookup and find its name in the router. At the end of
the day, named routes are arbitrary names that need to be memorized by developers, adding
cognitive overhead.

Verified routes tackle this problem by allowing the routes to be written as we would read them
in a browser, but using the `~p` sigil to guarantee they actually exist at compilation time.
They remove the indirection of named routes while keeping their guarantees.

In any case, if part of your application requires features similar to named routes, then
remember you can still leverage Elixir features to achieve the same result. For example,
you can define several functions as named routes to be reused across modules:

    def login_path, do: ~p"/login"
    def user_home_path(user), do: ~p"/users/#{user.username}"

## Options

To verify routes in your application modules, such as controller, templates, and views,
`use Phoenix.VerifiedRoutes`, which supports the following options:

  * `:router` - The required router to verify `~p` paths against
  * `:endpoint` - Optional endpoint for URL generation
  * `:statics` - Optional list of static directories to treat as verified paths
  * `:path_prefixes` - Optional list of path prefixes to be added to every generated path.
    See "Path prefixes" for more information

For example:

    use Phoenix.VerifiedRoutes,
      router: AppWeb.Router,
      endpoint: AppWeb.Endpoint,
      statics: ~w(images)

## Connection/socket-based route generation

The majority of path and URL generation needs your application will be met
with `~p` and `url/1`, where all information necessary to construct the path
or URL is provided by the compile-time information stored in the Endpoint
and Router passed to `use Phoenix.VerifiedRoutes`.

That said, there are some circumstances where `path/2`, `path/3`, `url/2`, and `url/3`
are required:

  * When the runtime values of the `%Plug.Conn{}`, `%Phoenix.LiveSocket{}`, or a `%URI{}`
    dictate the formation of the path or URL, which happens under the following scenarios:

    - `Phoenix.Controller.put_router_url/2` is used to override the endpoint's URL
    - `Phoenix.Controller.put_static_url/2` is used to override the endpoint's static URL

  * When the Router module differs from the one passed to `use Phoenix.VerifiedRoutes`,
    such as library code, or application code that relies on multiple routers. In such cases,
    the router module can be provided explicitly to `path/3` and `url/3`.

## Tracking warnings

All static path segments must start with forward slash, and you must have a static segment
between dynamic interpolations in order for a route to be verified without warnings.
For example, imagine you have these two routes:

    get "/media/posts/:id"
    get "/media/images/:id"

The following route will be verified and emit a warning as it does not match the router:

    ~p"/media/post/#{post}"

However the one below will not, the "post" segment is dynamic:

    type = "post"
    ~p"/media/#{type}/#{post}"

If you find yourself needing to generate dynamic URLs which are defined statically
in the router, that's a good indicator you should refactor it into one or more
function, such as `posts_path/1` and `images_path/1`.

Like any other compilation warning, the Elixir compiler will warn any time the file
that a `~p` resides in changes, or if the router is changed.

## Localized routes and path prefixes

Applications that need to support internationalization (i18n) and localization (l10n)
often do so at the URL level. In such cases, there are different approaches one can
choose.

One option is to perform i18n at the domain level. You can have `example.com` (in which
you would detect the locale based on the "Accept-Language" HTTP header), `en.example.com`,
`en-GB.example.com` and so forth. In this case, you would have a plug that looks at the
host and at HTTP headers and calls `Gettext.get_locale/1` accordingly. The biggest benefit
of this approach is that you don't have to change the routes in your application and
verified routes works as is.

Some applications, however, like to add the locale as part of the URL prefix:

    scope "/:locale" do
      get "/posts"
      get "/images"
    end

For such cases, VerifiedRoutes allow you to configure a `path_prefixes` option, which
is a list of segments to prepend to the URL. For example:

    use Phoenix.VerifiedRoutes,
      router: AppWeb.Router,
      endpoint: AppWeb.Endpoint,
      path_prefixes: [{Gettext, :get_locale, []}]

The above will prepend `"/#{Gettext.get_locale()}"` to every path and url generated with
`~p`. If your website has a handful of URLs that do not require the locale prefix, then
we suggest defining them in a separate module, where you use `Phoenix.VerifiedRoutes`
without the prefix option:

    defmodule UnlocalizedRoutes do
      use Phoenix.VerifiedRoutes,
        router: AppWeb.Router,
        endpoint: AppWeb.Endpoint

      # Since :path_prefixes was not declared,
      # the code below won't prepend the locale and still be verified
      def root, do: ~p"/"
    end

Finally, for even more complex use cases, where the whole URL needs to localized,
see projects such as [`routex`](https://hex.pm/packages/routex) and
[`ex_cldr_routes`](https://hex.pm/packages/ex_cldr_routes).

## Usage with custom plugs

Sometimes, when we want to do dynamic routing, we will forward to custom plugs.
It is possible to make these dynamic routers support `mix phx.routes` and verified
routes at compile time by adopting the `Phoenix.VerifiedRoutes` behaviour.
For example:

    defmodule MyApp.LocaleRouter do
      use Plug.Router
      @behaviour Phoenix.VerifiedRoutes

      # custom routing rules

      # for displaying in `mix phx.routes`
      def formatted_routes(plug_opts) do
        for locale <- supported_locales(plug_opts) do
          %{verb: "GET", path: "/#{locale}/*subpath"}
        end
      end

      def verified_route?(plug_opts, path) do
        plug_opts
        |> supported_locales()
        |> Enum.any?(fn locale ->
          Enum.at(path, 0) == locale
        end)
      end
    end

## static_integrity(conn_or_socket_or_endpoint, path)

Generates an integrity hash to a static asset given its file path.

See `c:Phoenix.Endpoint.static_integrity/1` for more information.

## Examples

    iex> static_integrity(conn, "/assets/js/app.js")
    "813dfe33b5c7f8388bccaaa38eec8382"

    iex> static_integrity(socket, "/assets/js/app.js")
    "813dfe33b5c7f8388bccaaa38eec8382"

    iex> static_integrity(AppWeb.Endpoint, "/assets/js/app.js")
    "813dfe33b5c7f8388bccaaa38eec8382"

## static_path(conn_or_socket_or_endpoint_or_uri, path)

Generates path to a static asset given its file path.

See `c:Phoenix.Endpoint.static_path/1` for more information.

## Examples

    iex> static_path(conn, "/assets/js/app.js")
    "/assets/js/app-813dfe33b5c7f8388bccaaa38eec8382.js"

    iex> static_path(socket, "assets/js/app.js")
    "/assets/js/app-813dfe33b5c7f8388bccaaa38eec8382.js"

    iex> static_path(AppWeb.Endpoint, "assets/js/app.js")
    "/assets/js/app-813dfe33b5c7f8388bccaaa38eec8382.js"

    iex> static_path(%URI{path: "/subresource"}, "/assets/js/app.js")
    "/subresource/assets/js/app-813dfe33b5c7f8388bccaaa38eec8382.js"

## static_url(conn_or_socket_or_endpoint, path)

Generates url to a static asset given its file path.

See `c:Phoenix.Endpoint.static_url/0` and `c:Phoenix.Endpoint.static_path/1` for more information.

## Examples

    iex> static_url(conn, "/assets/js/app.js")
    "https://example.com/assets/js/app-813dfe33b5c7f8388bccaaa38eec8382.js"

    iex> static_url(socket, "/assets/js/app.js")
    "https://example.com/assets/js/app-813dfe33b5c7f8388bccaaa38eec8382.js"

    iex> static_url(AppWeb.Endpoint, "/assets/js/app.js")
    "https://example.com/assets/js/app-813dfe33b5c7f8388bccaaa38eec8382.js"

## unverified_path(conn_or_socket_or_endpoint_or_uri, router, path, params \\ %{})

Returns the path with relevant script name prefixes without verification.

## Examples

    iex> unverified_path(conn, AppWeb.Router, "/posts")
    "/posts"

    iex> unverified_path(conn, AppWeb.Router, "/posts", page: 1)
    "/posts?page=1"

## unverified_url(conn_or_socket_or_endpoint_or_uri, path, params \\ %{})

Returns the URL for the endpoint from the path without verification.

## Examples

    iex> unverified_url(conn, "/posts")
    "https://example.com/posts"

    iex> unverified_url(conn, "/posts", page: 1)
    "https://example.com/posts?page=1"

## path(conn_or_socket_or_endpoint_or_uri, sigil_p)

Generates the router path with route verification.

See `sigil_p/2` for more information.

Warns when the provided path does not match against the router specified
in `use Phoenix.VerifiedRoutes` or the `@router` module attribute.

## Examples

    import Phoenix.VerifiedRoutes

    redirect(to: path(conn, ~p"/users/top"))

    redirect(to: path(conn, ~p"/users/#{@user}"))

    ~H"""
    <.link href={path(@uri, "/users?page=#{@page}")}>profile</.link>
    <.link href={path(@uri, "/users?#{@params}")}>profile</.link>
    """

## path(conn_or_socket_or_endpoint_or_uri, router, sigil_p)

Generates the router path with route verification.

See `sigil_p/2` for more information.

Warns when the provided path does not match against the router specified
in the router argument.

## Examples

    import Phoenix.VerifiedRoutes

    redirect(to: path(conn, MyAppWeb.Router, ~p"/users/top"))

    redirect(to: path(conn, MyAppWeb.Router, ~p"/users/#{@user}"))

    ~H"""
    <.link href={path(@uri, MyAppWeb.Router, "/users?page=#{@page}")}>profile</.link>
    <.link href={path(@uri, MyAppWeb.Router, "/users?#{@params}")}>profile</.link>
    """

## sigil_p(route, extra)

Generates the router path with route verification.

Interpolated named parameters are encoded via the `Phoenix.Param` protocol.

Warns when the provided path does not match against the router specified
in `use Phoenix.VerifiedRoutes` or the `@router` module attribute.

## Examples

    use Phoenix.VerifiedRoutes, endpoint: MyAppWeb.Endpoint, router: MyAppWeb.Router

    redirect(to: ~p"/users/top")

    redirect(to: ~p"/users/#{@user}")

    ~H"""
    <.link href={~p"/users?page=#{@page}"}>profile</.link>

    <.link href={~p"/users?#{@params}"}>profile</.link>
    """

## url(sigil_p)

Generates the router url with route verification.

See `sigil_p/2` for more information.

Warns when the provided path does not match against the router specified
in `use Phoenix.VerifiedRoutes` or the `@router` module attribute.

## Examples

    use Phoenix.VerifiedRoutes, endpoint: MyAppWeb.Endpoint, router: MyAppWeb.Router

    redirect(to: url(conn, ~p"/users/top"))

    redirect(to: url(conn, ~p"/users/#{@user}"))

    ~H"""
    <.link href={url(@uri, "/users?#{[page: @page]}")}>profile</.link>
    """

The router may also be provided in cases where you want to verify routes for a
router other than the one passed to `use Phoenix.VerifiedRoutes`:

    redirect(to: url(conn, OtherRouter, ~p"/users"))

Forwarded routes are also resolved automatically. For example, imagine you
have a forward path to an admin router in your main router:

    defmodule AppWeb.Router do
      ...
      forward "/admin", AppWeb.AdminRouter
    end

    defmodule AppWeb.AdminRouter do
      ...
      get "/users", AppWeb.Admin.UserController
    end

Forwarded paths in your main application router will be verified as usual,
such as `~p"/admin/users"`.

## url(conn_or_socket_or_endpoint_or_uri, sigil_p)

Generates the router url with route verification from the connection, socket, or URI.

See `url/1` for more information.

## url(conn_or_socket_or_endpoint_or_uri, router, sigil_p)

Generates the url with route verification from the connection, socket, or URI and router.

See `url/1` for more information.

## formatted_routes/1

Returns the necessary information about routes for display in `mix phx.routes`.

The `plug_opts` is typically only passed when the router is mounted within
a `Phoenix.Router`. Otherwise it defaults to `[]`.

## verified_route?/2

Returns `true` if the path is verified, and false if not.

The `plug_opts` is typically only passed when the router is mounted within
a `Phoenix.Router`. Otherwise it defaults to `[]`.