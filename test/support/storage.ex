defmodule Commanded.Storage do
  def reset! do
    nodes = nodes()

    Enum.each(nodes(), fn node ->
      Commanded.Cluster.rpc(node, Application, :stop, [:commanded])
    end)

    with {:ok, conn} <- EventStore.configuration() |> EventStore.Config.parse() |> Postgrex.start_link() do
      EventStore.Storage.Initializer.reset!(conn)
    end

    Enum.each(nodes, fn node ->
      Commanded.Cluster.rpc(node, Application, :ensure_all_started, [:swarm])
      Commanded.Cluster.rpc(node, Application, :ensure_all_started, [:eventstore])
      Commanded.Cluster.rpc(node, Application, :ensure_all_started, [:commanded])
    end)
  end

  defp nodes, do: [Node.self() | Node.list()]
end
