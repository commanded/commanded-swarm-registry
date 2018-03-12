defmodule Commanded.Registration.SwarmRegistry.ExampleSupervisor do
  use Supervisor

  alias Commanded.Registration.SupervisedServer

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      {SupervisedServer, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
