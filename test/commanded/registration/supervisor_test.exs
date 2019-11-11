defmodule Commanded.Registration.SupervisorTest do
  use ExUnit.Case

  alias Commanded.Helpers.Wait
  alias Commanded.Registration
  alias Commanded.Registration.SwarmRegistry.ExampleSupervisor
  alias Commanded.SwarmApp

  setup_all do
    start_supervised!(SwarmApp)
    start_supervised!(ExampleSupervisor)

    Wait.until(1_000, fn ->
      refute Registration.whereis_name(SwarmApp, "supervisedchild") == :undefined
    end)

    :ok
  end

  test "should restart supervised process on process shutdown" do
    pid = Registration.whereis_name(SwarmApp, "supervisedchild")

    # Shutdown supervised registered process
    shutdown(pid)

    # Process should be restarted by supervisor
    Wait.until(fn ->
      refute Registration.whereis_name(SwarmApp, "supervisedchild") == :undefined
    end)
  end

  def shutdown(pid) when is_pid(pid) do
    Process.unlink(pid)
    Process.exit(pid, :kill)

    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, _, _, _}, 5_000
  end
end
