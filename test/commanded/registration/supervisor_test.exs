defmodule Commanded.Registration.SupervisorTest do
  use ExUnit.Case

  alias Commanded.Registration
  alias Commanded.Helpers.{ProcessHelper, Wait}

  test "should restart supervised process on process shutdown" do
    Wait.until(fn ->
      refute Registration.whereis_name("supervisedchild") == :undefined
    end)

    pid = Registration.whereis_name("supervisedchild")

    # Shutdown supervised registered process
    shutdown(pid)

    # Process should be restarted by supervisor
    Wait.until(fn ->
      refute Registration.whereis_name("supervisedchild") == :undefined
    end)
  end

  def shutdown(pid) when is_pid(pid) do
    Process.unlink(pid)
    Process.exit(pid, :kill)

    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, _, _, _}, 5_000
  end
end
