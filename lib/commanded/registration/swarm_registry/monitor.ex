defmodule Commanded.Registration.SwarmRegistry.Monitor do
  @moduledoc """
  A `GenServer` process that starts and monitors another process that is
  distributed using Swarm.

  This is used to ensure the process can be supervised by a `Supervisor`.
  """

  use GenServer

  require Logger

  alias Commanded.Registration.SwarmRegistry.Monitor

  defstruct [:name, :module, :args, :pid, :ref]

  @doc false
  def start_link(name, module, args) do
    GenServer.start_link(__MODULE__, %Monitor{
      name: name,
      module: module,
      args: args
    })
  end

  @doc false
  def init(%Monitor{} = state) do
    send(self(), :start_distributed_process)

    {:ok, state}
  end

  @doc false
  def handle_cast(request, %Monitor{pid: pid} = state) when is_pid(pid) do
    GenServer.cast(pid, request)

    {:noreply, state}
  end

  @doc false
  def handle_call(request, _from, %Monitor{pid: pid} = state) when is_pid(pid) do
    reply = GenServer.call(pid, request)

    {:reply, reply, state}
  end

  @doc """
  Start a process using Swarm to distribute it amongst the available nodes in the cluster
  """
  def handle_info(:start_distributed_process, %Monitor{} = state) do
    %Monitor{name: name, module: module, args: args} = state

    debug(fn ->
      "[#{Node.self()}] Attempting to start distributed process: #{inspect(name)} (#{
        inspect(module)
      } with args #{inspect(args)})"
    end)

    case Swarm.register_name(name, GenServer, :start_link, [module, args]) do
      {:ok, pid} ->
        debug(fn ->
          "[#{inspect(Node.self())}] Started named process #{inspect(name)} on #{
            inspect(node(pid))
          } (#{inspect(pid)})"
        end)

        Process.unlink(pid)
        monitor(pid, state)

      {:error, {:already_registered, pid}} ->
        debug(fn ->
          "[#{inspect(Node.self())}] Named process #{inspect(name)} already started on #{
            inspect(node(pid))
          } (#{inspect(pid)})"
        end)

        monitor(pid, state)

      {:error, :no_node_available} ->
        debug(fn ->
          "[#{inspect(Node.self())}] Failed to start distributed process #{inspect(name)} due to no node available, will attempt to restart in 1s"
        end)

        attempt_process_restart()
        {:noreply, state}

      {:error, reason} ->
        info(fn ->
          "[#{inspect(Node.self())}] Failed to start distributed process #{inspect(name)} due to: #{
            inspect(reason)
          }"
        end)

        {:stop, reason, state}
    end
  end

  @doc """
  Attempt to restart the monitored process when it is shutdown, but requests
  restart, or due to `:noconnection` or `:noproc`.
  """
  def handle_info({:DOWN, ref, :process, _pid, reason}, %Monitor{name: name, ref: ref} = state)
      when reason in [:noconnection, :noproc, :shutdown, {:shutdown, :attempt_restart}] do
    debug(fn ->
      "[#{Node.self()}] Named process #{inspect(name)} down due to: #{inspect(reason)}"
    end)

    Process.demonitor(ref)
    attempt_process_restart()

    {:noreply, %Monitor{state | pid: nil, ref: nil}}
  end

  @doc """
  Stop the monitor when the monitored process is shutdown and requests not
  to be restarted.
  """
  def handle_info(
        {:DOWN, ref, :process, _pid, {:shutdown, :no_restart}},
        %Monitor{name: name, ref: ref} = state
      ) do
    debug(fn ->
      "[#{Node.self()}] Named process #{inspect(name)} down due to: {:shutdown, :no_restart}"
    end)

    stop(:shutdown, state)
  end

  @doc """
  Stop the monitor when the monitored process goes down for any other reason.
  """
  def handle_info({:DOWN, ref, :process, _pid, reason}, %Monitor{name: name, ref: ref} = state) do
    debug(fn ->
      "[#{Node.self()}] Named process #{inspect(name)} down due to: #{inspect(reason)}"
    end)

    stop(reason, state)
  end

  @doc """
  Send any other messages to the monitored process, if available
  """
  def handle_info(message, %Monitor{pid: pid} = state) when is_pid(pid) do
    send(pid, message)

    {:noreply, state}
  end

  defp stop(reason, %Monitor{ref: ref} = state) do
    Process.demonitor(ref)

    {:stop, reason, %Monitor{state | pid: nil, ref: nil}}
  end

  defp attempt_process_restart(delay \\ restart_delay()) do
    Process.send_after(self(), :start_distributed_process, delay)
  end

  defp monitor(pid, %Monitor{} = state) do
    ref = Process.monitor(pid)

    {:noreply, %Monitor{state | pid: pid, ref: ref}}
  end

  defp restart_delay do
    Application.get_env(:commanded_swarm_registry, :restart_delay, 1_000)
  end

  defdelegate debug(chardata_or_fun), to: Logger
  defdelegate info(chardata_or_fun), to: Logger
end
