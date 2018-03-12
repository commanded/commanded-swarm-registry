use Mix.Config

config :logger, :console, level: :debug, format: "[$level] $message\n"

config :ex_unit,
  capture_log: true,
  assert_receive_timeout: 5_000,
  refute_receive_timeout: 2_000

config :commanded,
  assert_receive_event_timeout: 2_000,
  registry: Commanded.Registration.SwarmRegistry

config :swarm,
  nodes: [:"node1@127.0.0.1", :"node2@127.0.0.1"],
  node_blacklist: [~r/^primary@.+$/],
  distribution_strategy: Swarm.Distribution.StaticQuorumRing,
  static_quorum_size: 2,
  sync_nodes_timeout: 0,
  debug: false
