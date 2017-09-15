use Mix.Config

config :logger, :console, level: :debug, format: "[$level] $message\n"

config :ex_unit,
  capture_log: true,
  assert_receive_timeout: 5_000,
  refute_receive_timeout: 2_000

config :commanded,
  event_store_adapter: Commanded.EventStore.Adapters.EventStore,
  reset_storage: &Commanded.Storage.reset!/0,
  registry: Commanded.Registration.SwarmRegistry

config :eventstore,
  registry: :distributed

config :eventstore, EventStore.Storage,
  serializer: Commanded.Serialization.JsonSerializer,
  username: "postgres",
  password: "postgres",
  database: "eventstore_test",
  hostname: "localhost",
  pool_size: 1

config :swarm,
  nodes: [:"node1@127.0.0.1", :"node2@127.0.0.1"],
  node_blacklist: [~r/^primary@.+$/],
  sync_nodes_timeout: 0,
  debug: false
