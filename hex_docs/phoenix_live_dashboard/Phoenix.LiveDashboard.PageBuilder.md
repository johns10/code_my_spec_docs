# Phoenix.LiveDashboard.PageBuilder

Page builder is the default mechanism for building custom dashboard pages.

Each dashboard page is a LiveView with additional callbacks for
customizing the menu appearance and the automatic refresh.

A simple and straight-forward example of a custom page is the
`Phoenix.LiveDashboard.EtsPage` that ships with the dashboard:

    defmodule Phoenix.LiveDashboard.EtsPage do
      @moduledoc false
      use Phoenix.LiveDashboard.PageBuilder

      @impl true
      def menu_link(_, _) do
        {:ok, "ETS"}
      end

      @impl true
      def render(assigns) do
        ~H"""
        <.live_table
          id="ets-table"
          dom_id="ets-table"
          page={@page}
          title="ETS"
          row_fetcher={&fetch_ets/2}
          row_attrs={&row_attrs/1}
          rows_name="tables"
        >
          <:col field={:name} header="Name or module" />
          <:col field={:protection} />
          <:col field={:type} />
          <:col field={:size} text_align="right" sortable={:desc} />
          <:col field={:memory} text_align="right" sortable={:desc} :let={ets}>
            <%= format_words(ets[:memory]) %>
          </:col>
          <:col field={:owner} :let={ets} >
            <%= encode_pid(ets[:owner]) %>
          </:col>
        </.live_table>
        """
      end

      defp fetch_ets(params, node) do
        %{search: search, sort_by: sort_by, sort_dir: sort_dir, limit: limit} = params

        # Here goes the code that goes through all ETS tables, searches
        # (if not nil), sorts, and limits them.
        #
        # It must return a tuple where the first element is list with
        # the current entries (up to limit) and an integer with the
        # total amount of entries.
        # ...
      end

      defp row_attrs(table) do
        [
          {"phx-click", "show_info"},
          {"phx-value-info", encode_ets(table[:id])},
          {"phx-page-loading", true}
        ]
      end
    end

Once a page is defined, it must be declared in your `live_dashboard`
route as follows:

    live_dashboard "/dashboard",
      additional_pages: [
        route_name: MyAppWeb.MyCustomPage
      ]

Or alternatively:

    live_dashboard "/dashboard",
      additional_pages: [
        route_name: {MyAppWeb.MyCustomPage, some_option: ...}
      ]

The second argument of the tuple will be given to the `c:init/1`
callback. If not tuple is given, `c:init/1` will receive an empty
list.

## Options for the use macro

The following options can be given when using the `PageBuilder` module:

* `refresher?` - Boolean to enable or disable the automatic refresh in the page.

## Components

A page can return any valid HEEx template in the `render/1` callback,
and it can use the components listed with this page too.

We currently support `card/1`, `fields_card/1`, `row/1`,
`shared_usage_card/1`, and `usage_card/1`;
and the live components `live_layered_graph/1`, `live_nav_bar/1`,
and `live_table/1`.

## Helpers

Some helpers are available for page building. The supported
helpers are: `live_dashboard_path/2`, `live_dashboard_path/3`,
`encode_app/1`, `encode_ets/1`, `encode_pid/1`, `encode_port/1`,
and `encode_socket/1`.

## Custom Hooks

If your page needs to register custom hooks, you can use the `register_after_opening_head_tag/2`
function. Because the hooks need to be available on the dead render in the layout, before the
LiveView's LiveSocket is configured, your need to do this inside an `on_mount` hook:

```elixir
defmodule MyAppWeb.MyLiveDashboardHooks do
  import Phoenix.LiveView
  import Phoenix.Component

  alias Phoenix.LiveDashboard.PageBuilder

  def on_mount(:default, _params, _session, socket) do
    {:cont, PageBuilder.register_after_opening_head_tag(socket, &after_opening_head_tag/1)}
  end

  defp after_opening_head_tag(assigns) do
    ~H"""
    <script nonce={@csp_nonces[:script]}>
      window.LiveDashboard.registerCustomHooks({
        MyHook: {
          mounted() {
            // do something
          }
        }
      })
    </script>
    """
  end
end

defmodule MyAppWeb.MyCustomPage do
  ...
end
```

And then add it to the list of `on_mount` hooks in the `live_dashboard` router configuration:

```elixir
live_dashboard "/dashboard",
  additional_pages: [
    route_name: MyAppWeb.MyCustomPage
  ],
  on_mount: [
    MyAppWeb.MyLiveDashboardHooks
  ]
```

The LiveDashboard provides a function `window.LiveDashboard.registerCustomHooks({ ... })` that you can call
with an object of hook declarations.

Note that in order to use external libraries, you will either need to include them from
a CDN, or bundle them yourself and include them from your app's static paths.

> #### A note on CSPs and libraries {: .info}
>
> Phoenix LiveDashboard supports CSP nonces for its own assets, configurable using the
> `Phoenix.LiveDashboard.Router.live_dashboard/2` macro by setting the `:csp_nonce_assign_key`
> option. If you are building a library, ensure that you render those CSP nonces on any scripts,
> styles or images of your page. The nonces are passed to your custom page under the `:csp_nonces` assign
> and also available in  the `after_opening_head_tag` component.
>
> You should use those when including scripts or styles like this:
>
> ```heex
> <script nonce={@csp_nonces.script}>...</script>
> <script nonce={@csp_nonces.script} src="..."></script>
> <style nonce={@csp_nonces.style}>...</style>
> <link rel="stylesheet" href="..." nonce={@csp_nonces.style}>
> ```
>
> This ensures that your custom page can be used when a CSP is in place using the mechanism
> supported by Phoenix LiveDashboard.
>
> If your custom page needs a different CSP policy, for example due to inline styles set by scripts,
> please consider documenting these requirements.

## card(assigns)

Card component.

You can see it in use the Home and OS Data pages.

## Attributes

* `title` (`:string`) - The title above the card. Defaults to `nil`.
* `hint` (`:string`) - A textual hint to show close to the title. Defaults to `nil`.
* `inner_title` (`:string`) - The title inside the card. Defaults to `nil`.
* `inner_hint` (`:string`) - A textual hint to show close to the inner title. Defaults to `nil`.
* `dom_id` (`:string`) - id attribute for the HTML the main tag. Defaults to `nil`.
## Slots

* `inner_block` (required) - The value that the card will show.

## card_title(assigns)

Card title component.

## Attributes

* `title` (`:string`) - The title above the card. Defaults to `nil`.
* `hint` (`:string`) - A textual hint to show close to the title. Defaults to `nil`.

## encode_app(app)

Encodes an application for URLs.

## Example

This function can be used to encode an application for an event value:

    <button phx-click="show-info" phx-value-info=<%= encode_app(@my_app) %>/>

## encode_ets(ref)

Encodes ETSs references for URLs.

## Example

This function can be used to encode an ETS reference for an event value:

    <button phx-click="show-info" phx-value-info=<%= encode_ets(@reference) %>/>

## encode_pid(pid)

Encodes PIDs for URLs.

## Example

This function can be used to encode a PID for an event value:

    <button phx-click="show-info" phx-value-info=<%= encode_pid(@pid) %>/>

## encode_port(port)

Encodes Port for URLs.

## Example

This function can be used to encode a Port for an event value:

    <button phx-click="show-info" phx-value-info=<%= encode_port(@port) %>/>

## encode_socket(ref)

Encodes Sockets for URLs.

## Example

This function can be used to encode `@socket` for an event value:

    <button phx-click="show-info" phx-value-info=<%= encode_socket(@socket) %>/>

## fields_card(assigns)

Fields card component.

You can see it in use the Home page in the Environment section.

## Attributes

* `fields` (`:list`) (required) - A list of key-value elements that will be shown inside the card.
* `title` (`:string`) - The title above the card. Defaults to `nil`.
* `hint` (`:string`) - A textual hint to show close to the title. Defaults to `nil`.
* `inner_title` (`:string`) - The title inside the card. Defaults to `nil`.
* `inner_hint` (`:string`) - A textual hint to show close to the inner title. Defaults to `nil`.

## hint(assigns)

Hint pop-up text component

## Attributes

* `text` (`:string`) (required) - Text to show in the hint.

## label_value_list(assigns)

List of label value.

You can see it in use in the modal in Ports or Processes page.

## Slots

* `elem` (required) - Value for each element of the list. Accepts attributes:

  * `label` (`:string`) (required) - Label for the elem.

## live_dashboard_path(socket, map)

Computes a router path to the current page.

## live_dashboard_path(socket, map, extra)

Computes a router path to the current page with merged params.

## live_layered_graph(assigns)

A component for drawing layered graphs.

This is useful to represent pipelines like we have on
[BroadwayDashboard](https://hexdocs.pm/broadway_dashboard) where
each layer points to nodes of the layer below.
It draws the layers from top to bottom.

The calculation of layers and positions is done automatically
based on options.


## Attributes

* `id` (`:any`) (required) - Because is a stateful `Phoenix.LiveComponent` an unique id is needed.
* `title` (`:string`) - The title of the component. Defaults to `nil`.
* `hint` (`:string`) - A textual hint to show close to the title. Defaults to `nil`.
* `layers` (`:list`) (required) - A graph of layers with nodes. They represent
  our graph structure (see example). Each layer is a list
  of nodes, where each node has the following fields:

    - `:id` - The ID of the given node.
    - `:children` - The IDs of children nodes.
    - `:data` - A string or a map. If it's a map, the required fields
      are `detail` and `label`.

* `show_grid?` (`:boolean`) - Enable or disable the display of a grid. This is useful for development. Defaults to `false`.
* `y_label_offset` (`:integer`) - The "y" offset of label position relative to the center of its circle. Defaults to `5`.
* `y_detail_offset` (`:integer`) - The "y" offset of detail position relative to the center of its circle. Defaults to `18`.
* `background` (`:any`) - A function that calculates the background for a
  node based on it's data. Default: `fn _node_data -> "gray" end`."

* `format_label` (`:any`) - A function that formats the label. Defaults
  to a function that returns the label or data if data is binary.

* `format_detail` (`:any`) - A function that formats the detail field.
  This is only going to be called if data is a map.
  Default: `fn node_data -> node_data.detail end`.



## Examples

    iex> layers = [
    ...>   [
    ...>     %{
    ...>       id: "a1",
    ...>       data: "a1",
    ...>       children: ["b1"]
    ...>     }
    ...>   ],
    ...>   [
    ...>     %{
    ...>       id: "b1"
    ...>       data: %{
    ...>         detail: 0,
    ...>         label: "b1"
    ...>       },
    ...>       children: []
    ...>      }
    ...>    ]
    ...> ]

## live_nav_bar(assigns)

Nav bar live component.

You can see it in use the Metrics and Ecto info pages.

## Attributes

* `id` (`:any`) (required) - Because is a stateful `Phoenix.LiveComponent` an unique id is needed.
* `page` (`Phoenix.LiveDashboard.PageBuilder`) (required) - Dashboard page.
* `nav_param` (`:string`) - An atom that configures the navigation parameter.
  It is useful when two nav bars are present in the same page.

  Defaults to `"nav"`.
* `extra_params` (`:list`) - A list of strings representing the parameters
  that should stay when a tab is clicked. By default the nav ignores
  all params, except the current node if any.

  Defaults to `[]`.
* `style` (`:atom`) - Style for the nav bar. Must be one of `:pills`, or `:bar`.
## Slots

* `item` (required) - HTML to be rendered when the tab is selected. Accepts attributes:

  * `name` (`:string`) (required) - Value used in the URL when the tab is selected.
  * `label` (`:string`) - Title of the tab. If it is not present, it will be calculated from `name`.
  * `method` (`:string`) - Method used to update. Must be one of `"patch"`, `"navigate"`, `"href"`, or `"redirect"`.

## live_table(assigns)

Table live component.

You can see it in use the applications, processes, sockets pages and many others.

## Attributes

* `id` (`:any`) (required) - Because is a stateful `Phoenix.LiveComponent` an unique id is needed.
* `page` (`Phoenix.LiveDashboard.PageBuilder`) (required) - Dashboard page.
* `row_fetcher` (`:any`) (required) - A function which receives the params and the node and
  returns a tuple with the rows and the total number:
  `(params(), node() -> {list(), integer() | binary()})`.
  Optionally, if the function needs to keep a state, it can be defined as a tuple
  where the first element is a function and the second is the initial state.
  In this case, the function will receive the state as third argument and must return
  a tuple with the rows, the total number, and the new state for the following call:
  `{(params(), node(), term() -> {list(), integer() | binary(), term()}), term()}`

* `rows_name` (`:string`) - A string to name the representation of the rows. Default is calculated from the current page.
* `row_attrs` (`:any`) - A list with the HTML attributes for the table row.
  It can be also a function that receive the row as argument
  and returns a list of 2 element tuple with HTML attribute name
  and value.

  Defaults to `nil`.
* `default_sort_by` (`:any`) - The default column to sort by to. Defaults to the first sortable column. Defaults to `nil`.
* `title` (`:string`) (required) - The title of the table.
* `limit` (`:any`) - May be set to `false` to disable the `limit`. Defaults to `[50, 100, 500, 1000, 5000]`.
* `search` (`:boolean`) - A boolean indicating if the search functionality is enabled. Defaults to `true`.
* `hint` (`:string`) - A textual hint to show close to the title. Defaults to `nil`.
* `dom_id` (`:string`) - id attribute for the HTML the main tag. Defaults to `nil`.
## Slots

* `col` (required) - Columns for the table. Accepts attributes:

  * `field` (`:atom`) (required) - Identifier for the column.
  * `sortable` (`:atom`) - When set, the column header is clickable and it fetches again rows with the new order.
    Required for at least one column.
 Must be one of `:asc`, or `:desc`.
  * `header` (`:string`) - Label to show in the current column. Default value is calculated from `:field`.
  * `text_align` (`:string`) - Text align for text in the column. Default: `nil`. Must be one of `"left"`, `"center"`, `"right"`, or `"justify"`.

## register_after_opening_head_tag(socket, component)

Registers a component to be rendered after the opening head tag in the layout.

## register_before_closing_head_tag(socket, component)

Registers a component to be rendered before the closing head tag in the layout.

## row(assigns)

Row component.

You can see it in use the Home page and OS Data pages.

## Slots

* `col` (required) - A list of components. It can receive up to 3 components. Each element will be one column.

## shared_usage_card(assigns)

Shared usage card component.

You can see it in use the Home page and OS Data pages.

## Attributes

* `usages` (`:list`) (required) - A list of `Map` with the following keys:
    * `:data` - A list of tuples with 4 elements with the following data: `{usage_name, usage_percent, color, hint}`
    * `:dom_id` - Required. Usage identifier.
    * `:title`- Bar title.

* `total_data` (`:any`) (required) - A list of tuples with 4 elements with following data: `{usage_name, usage_value, color, hint}`.
* `total_legend` (`:string`) (required) - The legent of the total usage.
* `total_usage` (`:string`) (required) - The value of the total usage.
* `dom_id` (`:string`) - id attribute for the HTML the main tag. Defaults to `nil`.
* `csp_nonces` (`:any`) (required) - A copy of CSP nonces (`@csp_nonces`) used to render the page safely.
* `title` (`:string`) - The title above the card. Defaults to `nil`.
* `hint` (`:string`) - A textual hint to show close to the title. Defaults to `nil`.
* `inner_title` (`:string`) - The title inside the card. Defaults to `nil`.
* `inner_hint` (`:string`) - A textual hint to show close to the inner title. Defaults to `nil`.
* `total_formatter` (`:any`) - A function that format the `total_usage`. Default: `&("#{&1} %")`. Defaults to `nil`.

## usage_card(assigns)

Usage card component.

You can see it in use the Home page and OS Data pages.

## Attributes

* `title` (`:string`) - The title above the card. Defaults to `nil`.
* `hint` (`:string`) - A textual hint to show close to the title. Defaults to `nil`.
* `dom_id` (`:string`) (required) - A unique identifier for all usages in this card.
* `csp_nonces` (`:any`) (required) - A copy of CSP nonces (`@csp_nonces`) used to render the page safely.
## Slots

* `usage` (required) - List of usages to show. Accepts attributes:

  * `current` (`:integer`) (required) - The current value of the usage.
  * `limit` (`:integer`) (required) - The max value of usage.
  * `dom_id` (`:string`) (required) - An unique identifier for the usage that will be concatenated to `dom_id`.
  * `percent` (`:string`) - The used percent of the usage.
  * `title` (`:string`) - The title of the usage.
  * `hint` (`:string`) - A textual hint to show close to the usage title.

## handle_event/3

Callback invoked when an event is called.

Note that `show_info` event is handled automatically by
`Phoenix.LiveDashboard.PageBuilder`,
but the `info` parameter (`phx-value-info`) needs to be encoded with
one of the `encode_*` helper functions.

For more details, see [`Phoenix.LiveView bindings`](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#module-bindings)

## handle_refresh/1

Callback invoked when the automatic refresh is enabled.

## init/1

Callback invoked when a page is declared in the router.

It receives the router options and it must return the
tuple `{:ok, session, requirements}`.

The page session will be serialized to the client and
received on `mount`.

The requirements is an optional keyword to detect the
state of the node.

The result of this detection will be passed as second
argument in the `c:menu_link/2` callback.
The possible values are:

  * `:applications` list of applications that are running or not.
  * `:modules` list of modules that are loaded or not.
  * `:pids` list of processes that alive or not.

## menu_link/2

Callback invoked when a page is declared in the router.

It receives the session returned by the `c:init/1` callback
and the capabilities of the current node.

The possible return values are:

  * `{:ok, text}` when the link should be enable and text to be shown.

  * `{:disabled, text}` when the link should be disable and text to be shown.

  * `{:disabled, text, more_info_url}` similar to the previous one but
    it also includes a link to provide more information to the user.

  * `:skip` when the link should not be shown at all.