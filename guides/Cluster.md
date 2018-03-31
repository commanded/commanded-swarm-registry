# Cluster

## Cluster formation on node start

You can configure the `:kernel` application to wait for cluster formation before starting your application during node start up. The `sync_nodes_optional` configuration specifies which nodes to attempt to connect to within the `sync_nodes_timeout` window, defined in milliseconds, before continuing with startup. There is also a `sync_nodes_mandatory` setting which can be used to enforce all nodes are connected within the timeout window or else the node terminates.

```elixir
config :kernel,
  sync_nodes_optional: [:"node1@192.168.1.1", :"node2@192.168.1.2"],
  sync_nodes_timeout: 30_000
```

The `sync_nodes_timeout` can be configured as `:infinity` to wait indefinitely for all nodes to
connect. All involved nodes must have the same value for `sync_nodes_timeout`.

This approach will only work for Elixir releases. You will need to use [Erlang's `sys.config`](http://erlang.org/doc/man/config.html) file for development purposes.

The Erlang equivalent of the `:kernerl` mix config, as above, is:

```erlang
[{kernel,
  [
    {sync_nodes_optional, ['node1@127.0.0.1', 'node2@127.0.0.1']},
    {sync_nodes_timeout, 30000}
  ]}
].
```

## Starting a cluster

  1. Run an [Erlang Port Mapper Daemon](http://erlang.org/doc/man/epmd.html) (epmd):

      ```console
      $ epmd -d
      ```

  2. Start an `iex` console per node:

      ```console
      $ MIX_ENV=test iex --name node1@127.0.0.1 --erl "-config cluster/node1.sys.config" -S mix
      ```

      ```console
      $ MIX_ENV=test iex --name node2@127.0.0.1 --erl "-config cluster/node2.sys.config" -S mix
      ```

      ```console
      $ MIX_ENV=test iex --name node3@127.0.0.1 --erl "-config cluster/node3.sys.config" -S mix
      ```

The node specific `<node>.sys.config` files ensure the cluster is formed before starting the application, assuming this occurs within the 30 seconds timeout.
