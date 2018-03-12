defmodule Commanded.Registration.SupervisorTest do
  use ExUnit.Case

  alias Commanded.Registration
  alias Commanded.Helpers.{ProcessHelper, Wait}

  @tag :wip
  test "should restart supervised process on process shutdown" do
    Wait.until(fn ->
      refute Registration.whereis_name("supervisedchild") == :undefined
    end)

    pid = Registration.whereis_name("supervisedchild")

    # Shutdown supervised registered process
    ProcessHelper.shutdown(pid)

    # Process should be restarted by supervisor
    Wait.until(fn ->
      refute Registration.whereis_name("supervisedchild") == :undefined
    end)
  end
end
