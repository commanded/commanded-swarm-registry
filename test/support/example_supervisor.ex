defmodule Commanded.Registration.SwarmRegistry.ExampleSupervisor do
  use Supervisor

  alias Commanded.Registration.SupervisedServer

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    children = [
      {SupervisedServer, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
