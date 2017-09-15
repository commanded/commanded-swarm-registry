defmodule Commanded.Registration.SwarmRegistry.CountEventHandler do
  @moduledoc false
  use Commanded.Event.Handler, name: __MODULE__

  def init do
    with {:ok, _pid} <- Agent.start_link(fn -> 0 end, name: __MODULE__) do
      :ok
    end
  end

  def handle(_event, _metadata) do
    Agent.update(__MODULE__, fn count -> count + 1 end)
  end

  def get_count do
    Agent.get(__MODULE__, fn count -> count end)
  end
end
