defmodule Commanded.SwarmApp do
  alias Commanded.EventStore.Adapters.InMemory
  alias Commanded.Registration.SwarmRegistry
  alias Commanded.Serialization.JsonSerializer

  use Commanded.Application,
    otp_app: :commanded,
    event_store: [
      adapter: InMemory,
      serializer: JsonSerializer
    ],
    pubsub: :local,
    registry: SwarmRegistry
end
