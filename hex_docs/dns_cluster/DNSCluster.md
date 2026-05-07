# DNSCluster

Simple DNS based cluster discovery.

A DNS query is made every `:interval` milliseconds to discover new ips.

## Default node discovery
Nodes will only be joined if their node basename matches the basename of the current node.
For example, if `node()` is `myapp-123@fdaa:1:36c9:a7b:198:c4b1:73c6:1`, it will try to connect
to every IP from the DNS query with `Node.connect/1`. But this will only work if the remote node
has the same basename, like `myapp-123@fdaa:1:36c9:a7b:198:c4b1:73c6:2`. If the remote node's
basename is different, the nodes will not connect.

## Specifying remote basenames
If you want to connect to nodes with different basenames, use a tuple with the basename and query.
For example, to connect to a node named `remote`, use `{"remote", "remote-app.internal"}`.

## Multiple queries
Sometimes you might want to cluster apps with different domain names. Just pass a list of queries
for this. For instance: `["app-one.internal", "app-two.internal", {"other-basename", "other.internal"}]`.
Remember, all nodes need to share the same secret cookie to connect successfully.

## Examples

To start in your supervision tree, add the child:

    children = [
      ...,
      {DNSCluster, query: "myapp.internal"}
    ]

See the `start_link/1` docs for all available options.

If you require more advanced clustering options and strategies, see the
[libcluster](https://hexdocs.pm/libcluster) library.

## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.

## start_link(opts)

Starts DNS based cluster discovery.

## Options

  * `:name` - the name of the cluster. Defaults to `DNSCluster`.
  * `:query` - the required DNS query for node discovery, for example:
    `"myapp.internal"` or `["foo.internal", "bar.internal"]`. If the basename
    differs between nodes, a tuple of `{basename, query}` can be provided as well.
    The value `:ignore` can be used to ignore starting the DNSCluster.
  * `:interval` - the millisec interval between DNS queries. Defaults to `5000`.
  * `:connect_timeout` - the millisec timeout to allow discovered nodes to connect.
    Defaults to `10_000`.

## Examples

    iex> DNSCluster.start_link(query: "myapp.internal")
    {:ok, pid}

    iex> DNSCluster.start_link(query: :ignore)
    :ignore