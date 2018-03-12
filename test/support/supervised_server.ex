defmodule Commanded.Registration.SupervisedServer do
  use GenServer
  use Commanded.Registration

  def start_link(_args) do
    Registration.start_link("supervisedchild", __MODULE__, [])
  end

  def init(state), do: {:ok, state}
end
