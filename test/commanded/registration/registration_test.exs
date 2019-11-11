defmodule Commanded.RegistrationTest do
  use ExUnit.Case

  alias Commanded.Registration
  alias Commanded.SwarmApp
  alias Commanded.Helpers.{ProcessHelper, Wait}
  alias Commanded.Registration.{RegisteredServer, RegisteredSupervisor}

  setup_all do
    start_supervised!(SwarmApp)

    Wait.until(fn ->
      case RegisteredSupervisor.start_child(SwarmApp, "startup") do
        {:ok, pid} when is_pid(pid) -> :ok
        {:error, :no_node_available} -> flunk("no node available")
      end
    end)
  end

  describe "`start_child/3`" do
    setup do
      on_exit(fn ->
        case Registration.whereis_name(SwarmApp, "child") do
          pid when is_pid(pid) ->
            ProcessHelper.shutdown(pid)

          _ ->
            :ok
        end
      end)
    end

    test "should return child process PID on success" do
      assert {:ok, _pid} = RegisteredSupervisor.start_child(SwarmApp, "child")
    end

    test "should return existing child process when already started" do
      assert {:ok, pid} = RegisteredSupervisor.start_child(SwarmApp, "child")
      assert {:ok, ^pid} = RegisteredSupervisor.start_child(SwarmApp, "child")
    end
  end

  describe "`start_link/3`" do
    setup do
      on_exit(fn ->
        case Registration.whereis_name(SwarmApp, "registered") do
          pid when is_pid(pid) ->
            ProcessHelper.shutdown(pid)

          _ ->
            :ok
        end
      end)
    end

    test "should return process PID on success" do
      assert {:ok, _pid} = start_link("registered")
    end

    test "should return existing process when already started" do
      assert {:ok, _pid} = start_link("registered")
      assert {:ok, _pid} = start_link("registered")

      Wait.until(fn ->
        refute Registration.whereis_name(SwarmApp, "registered") == :undefined
      end)
    end
  end

  describe "`whereis_name/1`" do
    test "should return `:undefined` when not registered" do
      assert Registration.whereis_name(SwarmApp, "notregistered") == :undefined
    end

    test "should return PID when child registered" do
      assert {:ok, pid} = RegisteredSupervisor.start_child(SwarmApp, "exists")
      assert Registration.whereis_name(SwarmApp, "exists") == pid
    end

    test "should return PID when process registered" do
      assert {:ok, _pid} = start_link("registered")

      Wait.until(fn ->
        refute Registration.whereis_name(SwarmApp, "registered") == :undefined
      end)
    end
  end

  defp start_link(name) do
    Registration.start_link(SwarmApp, name, RegisteredServer, [name])
  end
end
