defmodule Commanded.Registration.SwarmRegistry.ExampleSupervisor do
  use Supervisor

  alias Commanded.Registration.SwarmRegistry.{AppendingEventHandler,CountEventHandler}

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_arg) do
    children = [
      {AppendingEventHandler, []},
      {CountEventHandler, []},
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
