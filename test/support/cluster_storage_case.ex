defmodule Commanded.ClusterStorageCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  require Logger

  setup do
    before_reset()
    reset_storage!()
    after_reset()

    :ok
  end

  defp before_reset do
    Application.stop(:swarm)

    nodes()
    |> Enum.map(&Task.async(fn ->
      :ok = Commanded.Cluster.rpc(&1, Application, :stop, [:eventstore])
      :ok = Commanded.Cluster.rpc(&1, Application, :stop, [:commanded])
    end))
    |> Enum.map(&Task.await(&1, 5_000))
  end

  defp reset_storage! do
    with {:ok, conn} <- EventStore.configuration() |> EventStore.Config.parse() |> Postgrex.start_link() do
      EventStore.Storage.Initializer.reset!(conn)
    end
  end

  defp after_reset do
    nodes()
    |> Enum.map(&Task.async(fn ->
      {:ok, _} = Commanded.Cluster.rpc(&1, Application, :ensure_all_started, [:swarm])
      {:ok, _} = Commanded.Cluster.rpc(&1, Application, :ensure_all_started, [:eventstore])
      {:ok, _} = Commanded.Cluster.rpc(&1, Application, :ensure_all_started, [:commanded])
    end))
    |> Enum.map(&Task.await(&1, 5_000))
  end

  defp nodes, do: [Node.self() | Node.list(:connected)]
end
