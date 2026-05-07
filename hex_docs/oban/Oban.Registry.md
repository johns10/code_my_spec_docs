# Oban.Registry

Local process storage for Oban instances.

## config(oban_name)

Fetch the config for an Oban supervisor instance.

## Example

Get the default instance config:

    Oban.Registry.config(Oban)

Get config for a custom named instance:

    Oban.Registry.config(MyApp.Oban)

## lookup(oban_name, role \\ nil)

Find the `{pid, value}` pair for a registered Oban process.

## Example

Get the default instance config:

    Oban.Registry.lookup(Oban)

Get a supervised module's pid:

    Oban.Registry.lookup(Oban, Oban.Notifier)

## select(spec)

Select details of registered Oban processes using a full match spec.

## Example

Get a list of all running Oban instances:

    Oban.Registry.select([{{:"$1", :_, :_}, [{:is_atom, :"$1"}], [:"$1"]}])

## via(oban_name, role \\ nil, value \\ nil)

Build a via tuple suitable for calls to a supervised Oban process.

## Example

For an Oban supervisor:

    Oban.Registry.via(Oban)

For a supervised module:

    Oban.Registry.via(Oban, Oban.Notifier)

For a plugin:

    Oban.Registry.via(Oban, {:plugin, Oban.Plugins.Cron})

## whereis(oban_name, role \\ nil)

Returns the pid of a supervised Oban process, or `nil` if the process can't be found.

## Example

Get the Oban supervisor's pid:

    Oban.Registry.whereis(Oban)

Get a supervised module's pid:

    Oban.Registry.whereis(Oban, Oban.Notifier)

Get the pid for a plugin:

    Oban.Registry.whereis(Oban, {:plugin, MyApp.Oban.Plugin})

Get the pid for a queue's producer:

    Oban.Registry.whereis(Oban, {:producer, "default"})