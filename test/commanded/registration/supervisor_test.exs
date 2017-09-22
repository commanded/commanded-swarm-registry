defmodule Commanded.Registration.SupervisorTest do
  use Commanded.ClusterStorageCase

  alias Commanded.Event.Handler
  alias Commanded.Registration.SwarmRegistry
  alias Commanded.Registration.SwarmRegistry.{AppendingEventHandler,CountEventHandler,ExampleSupervisor}
  alias Commanded.Helpers.{ProcessHelper,Wait}

  test "should restart supervised process on process shutdown" do
    for node <- nodes() do
      {:ok, _pid} = Commanded.Cluster.rpc(node, ExampleSupervisor, :start_link, [])
    end

    appending_process_name = AppendingEventHandler |> inspect() |> Handler.name()
    counter_process_name = CountEventHandler |> inspect() |> Handler.name()

    :timer.sleep 1_000

    for node <- nodes() do
      registered = Commanded.Cluster.rpc(node, Swarm, :registered, []) |> Enum.sort_by(fn {name, _pid} -> name end)

      assert [
        {^appending_process_name, appending_pid},
        {^counter_process_name, counter_pid},
      ] = registered

      assert Commanded.Cluster.rpc(node, SwarmRegistry, :whereis_name, [appending_process_name]) == appending_pid
      assert Commanded.Cluster.rpc(node, SwarmRegistry, :whereis_name, [counter_process_name]) == counter_pid
    end

    # shutdown one of the handlers to test that it is restarted by the supervisor
    appending_pid = Commanded.Cluster.rpc(:"node1@127.0.0.1", SwarmRegistry, :whereis_name, [appending_process_name])
    counter_pid = Commanded.Cluster.rpc(:"node1@127.0.0.1", SwarmRegistry, :whereis_name, [counter_process_name])

    ProcessHelper.shutdown(appending_pid)

    :timer.sleep 1_000

    # ensure Supervisor has restarted the shutdown event handler
    Wait.until(fn ->
      pid = Commanded.Cluster.rpc(:"node1@127.0.0.1", SwarmRegistry, :whereis_name, [appending_process_name])

      refute pid == :undefined
      refute pid == appending_pid
    end)

    # ensure other handler has not been restarted
    assert counter_pid == Commanded.Cluster.rpc(:"node1@127.0.0.1", SwarmRegistry, :whereis_name, [counter_process_name])
  end

  defp nodes, do: Application.get_env(:swarm, :nodes, [])
end
