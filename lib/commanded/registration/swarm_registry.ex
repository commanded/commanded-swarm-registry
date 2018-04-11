defmodule Commanded.Registration.SwarmRegistry do
  @moduledoc """
  Process registration and distribution throughout a cluster of nodes using
  [Swarm](https://github.com/bitwalker/swarm).
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
  Starts a uniquely named child process of a supervisor using the given module
  and args.

  Registers the pid with the given name.
  """
  @spec start_child(name :: term(), supervisor :: module(), args :: [any()]) ::
          {:ok, pid} | {:error, term}
  @impl Commanded.Registration
  def start_child(name, supervisor, args) do
    case Swarm.register_name(name, Supervisor, :start_child, [supervisor, args]) do
      {:error, {:already_registered, pid}} -> {:error, {:already_started, pid}}
      reply -> reply
    end
  end

  @doc """
  Starts a uniquely named `GenServer` process for the given module and args.

  Registers the pid with the given name.
  """
  @spec start_link(name :: term(), module :: module(), args :: [any()]) ::
          {:ok, pid} | {:error, term}
  @impl Commanded.Registration
  def start_link(name, module, args), do: Monitor.start_link(name, module, args)

  @doc """
  Get the pid of a registered name.
  """
  @spec whereis_name(name :: term) :: pid | :undefined
  @impl Commanded.Registration
  def whereis_name(name), do: Swarm.whereis_name(name)

  @doc """
  Return a `:via` tuple to route a message to a process by its registered name.
  """
  @spec via_tuple(name :: term()) :: {:via, module(), name :: term()}
  @impl Commanded.Registration
  def via_tuple(name), do: {:via, :swarm, name}

  #
  # `GenServer` callback functions used by Swarm
  #

  @doc false
  def handle_call({:swarm, :begin_handoff}, _from, state) do
    # Stop the process when a cluster toplogy change indicates it is now running
    # on the wrong host. This is to prevent a spike in process restarts as they
    # are moved. Instead, allow the process to be started on request.
    {:stop, {:shutdown, :no_restart}, :ignore, state}
  end

  @doc false
  def handle_call(_request, _from, _state) do
    raise "attempted to call GenServer #{inspect(proc())} but no handle_call/3 clause was provided"
  end

  @doc false
  def handle_cast({:swarm, :end_handoff, _state}, state) do
    {:noreply, state}
  end

  @doc false
  def handle_cast({:swarm, :resolve_conflict, state}, _state) do
    {:noreply, state}
  end

  @doc false
  def handle_cast(_request, _state) do
    raise "attempted to cast GenServer #{inspect(proc())} but no handle_cast/2 clause was provided"
  end

  @doc false
  def handle_info({:swarm, :die}, state) do
    # Stop the process as there are not currently enough nodes running to host
    # it, but attempt to restart it when a node becomes available
    {:stop, {:shutdown, :attempt_restart}, state}
  end

  @doc false
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp proc do
    case Process.info(self(), :registered_name) do
      {_, []} -> self()
      {_, name} -> name
    end
  end
end
