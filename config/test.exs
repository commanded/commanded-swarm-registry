use Mix.Config

config :commanded,
  event_store_adapter: Commanded.EventStore.Adapters.InMemory,
  registry: Commanded.Registration.SwarmRegistry,
  reset_storage: fn ->
    {:ok, _event_store} = Commanded.EventStore.Adapters.InMemory.start_link()
  end
