defmodule Commanded.Registration.SwarmRegistry do
  @moduledoc """
  Process registration and distribution throughout a cluster of nodes using [Swarm](https://github.com/bitwalker/swarm)
  """

  @behaviour Commanded.Registration

  alias Commanded.Registration.SwarmRegistry.Monitor

  @doc """
  Return an optional supervisor spec for the registry
  """
  @spec child_spec() :: [:supervisor.child_spec()]
  @impl Commanded.Registration
  def child_spec, do: []

  @doc """
  Starts a uniquely named child process of a supervisor using the given module and args.

  Registers the pid with the given name.
  """
  @spec start_child(name :: term(), supervisor :: module(), args :: [any()]) :: {:ok, pid()} | {:error, reason :: term()}
  @impl Commanded.Registration
  def start_child(name, supervisor, args) do
    case whereis_name(name) do
      :undefined ->
        case Swarm.register_name(name, Supervisor, :start_child, [supervisor, args]) do
          {:error, {:already_registered, pid}} -> {:error, {:already_started, pid}}
          reply -> reply
        end

      pid ->
        Process.link(pid)
        {:ok, pid}
    end
  end

  @doc """
  Starts a uniquely named `GenServer` process for the given module and args.

  Registers the pid with the given name.
  """
  @spec start_link(name :: term(), module :: module(), args :: [any()]) :: {:ok, pid()} | {:error, reason :: term()}
  @impl Commanded.Registration
  def start_link(name, module, args), do: Monitor.start_link(name, module, args)

  @doc """
  Get the pid of a registered name.
  """
  @spec whereis_name(name :: term) :: pid | :undefined
  @impl Commanded.Registration
  def whereis_name(name), do: Swarm.whereis_name(name)

  @doc """
  Return a `:via` tuple to route a message to a process by its registered name
  """
  @spec via_tuple(name :: term()) :: {:via, module(), name :: term()}
  @impl Commanded.Registration
  def via_tuple(name), do: {:via, :swarm, name}

  #
  # `GenServer` callback functions used by Swarm
  #

  # Shutdown the process when a cluster toplogy change indicates it is now running on the wrong host.
  # This is to prevent a spike in process restarts as they are moved.
  # Instead, allow the process to be started on request.
  def handle_call({:swarm, :begin_handoff}, _from, state) do
    {:stop, :shutdown, :ignore, state}
  end

  # Unused
  def handle_cast({:swarm, :end_handoff, _state}, state) do
    {:noreply, state}
  end

  # Unused
  def handle_cast({:swarm, :resolve_conflict, state}, _state) do
    {:noreply, state}
  end

  # Stop the process as it is being moved to another node, or there are not currently enough nodes running
  def handle_info({:swarm, :die}, state) do
    {:stop, :shutdown, state}
  end
end
