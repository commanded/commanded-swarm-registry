defmodule Commanded.AggregateTest do
  use ExUnit.Case

  alias Commanded.ExampleDomain.BankAccount
  alias Commanded.Helpers.{ProcessHelper, Wait}
  alias Commanded.Registration
  alias Commanded.Registration.{RegisteredServer, RegisteredSupervisor}

  setup_all do
    Wait.until(fn ->
      case RegisteredSupervisor.start_child("startup") do
        {:ok, pid} when is_pid(pid) -> :ok
        {:error, :no_node_available} -> flunk("no node available")
      end
    end)
  end

  test "should `start_child/3` for an aggregate process" do
    assert {:ok, "ACC1234"} =
             Commanded.Aggregates.Supervisor.open_aggregate(BankAccount, "ACC1234")

    pid = Commanded.Registration.whereis_name({BankAccount, "ACC1234"})
    assert is_pid(pid)
  end
end
