# Getting started

Commanded Swarm registry can be installed from hex as follows.

1. Add `commanded_swarm_registry` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:commanded_swarm_registry, "~> 0.1"}]
    end
    ```

2. Fetch mix dependencies:

    ```console
    $ mix deps.get
    ```

3. Configure your Commanded application to use the Swarm registry (e.g. `config/config.exs`):

    ```elixir
    config :commanded,
      registry: Commanded.Registration.SwarmRegistry
    ```
