defmodule Commanded.Registration.SwarmRegistry.Monitor do
  @moduledoc """
  A `GenServer` process that starts and monitors another process that is distributed using Swarm.

  This is used to ensure the process can be supervised by a `Supervisor`.
  """

  use GenServer

  require Logger

  alias Commanded.Registration.SwarmRegistry.Monitor

  defstruct [:name, :pid]

  @doc false
  def start_link(name, module, args) do
    GenServer.start_link(__MODULE__, [name, module, args])
  end

  @doc false
  def init([name, module, args]) do
    GenServer.cast(self(), {:start_distributed_process, module, args})
    {:ok, %Monitor{name: name}}
  end

  @doc """
  Start a process using Swarm to distribute it amongst the available nodes in the cluster
  """
  def handle_cast({:start_distributed_process, module, args}, %Monitor{name: name} = state) do
    Logger.debug(fn -> "[#{Node.self()}] Attempting to start distributed process: #{inspect name} (#{inspect module} with args #{inspect args})" end)

    case Swarm.whereis_name(name) do
      :undefined ->
        case Swarm.register_name(name, GenServer, :start_link, [module, args]) do
          {:ok, pid} ->
            monitor(pid, state)

          {:error, {:already_registered, pid}} ->
            monitor(pid, state)

          {:error, reason} ->
            Logger.info(fn -> "[#{inspect Node.self()}] Failed to start distributed process \"#{inspect name}\" due to: #{inspect reason}" end)
            {:stop, reason, state}
        end

      pid ->
        monitor(pid, state)
    end
  end

  @doc """
  Stop the process when the monitored process goes down
  """
  def handle_info({:DOWN, _ref, :process, _pid, reason}, name) do
    Logger.debug(fn -> "[#{Node.self()}] Named process \"#{inspect name}\" down due to: #{inspect reason}" end)
    {:stop, reason, name}
  end

  @doc """
  Send any other messages to the monitored process, if available
  """
  def handle_info(message, %Monitor{pid: pid} = state) when is_pid(pid) do
    send(pid, message)
    {:noreply, state}
  end

  defp monitor(pid, %Monitor{} = state) do
    Process.monitor(pid)

    {:noreply, %Monitor{state | pid: pid}}
  end
end
