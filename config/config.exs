use Mix.Config

config :commanded_swarm_registry,
  restart_delay: 1_000

import_config "#{Mix.env}.exs"
