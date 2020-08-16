defmodule TanksGame.Server do
  use GenServer
  require Logger

  @registry :servers_registry
  @tickms 16

  @initial_state %{
    id: nil,
    x: 0,
    y: 0,
    input: %{
      left: false,
      right: false,
      up: false,
      down: false
    }
  }

  # API

  def start_link(id) do
    GenServer.start_link(__MODULE__, id, name: via_tuple(id))
  end

  def state(id) do
    GenServer.call(via_tuple(id), :state)
  end

  def stop(id) do
    GenServer.stop(via_tuple(id))
  end

  def crash(id) do
    GenServer.cast(via_tuple(id), :raise)
  end

  def send_input(id, input) do
    GenServer.cast(via_tuple(id), {:update_input, input})
  end

  # Callbacks

  def init(id) do
    Logger.info("Starting #{__MODULE__} #{id}")

    Process.send_after(self(), :tick, @tickms)

    {:ok, %{@initial_state | id: id}}
  end

  def handle_info(:tick, state) do
    new_state = do_tick(state)

    TanksWeb.Endpoint.broadcast!("game:#{state.id}", "tick", state_for_client(new_state))

    Process.send_after(self(), :tick, @tickms)
    {:noreply, new_state}
  end

  def handle_call(:state, _from, state) do
    {:reply, {:ok, state}, state}
  end

  def handle_cast({:update_input, input}, state) do
    new_state = %{state | input: input}
    {:noreply, new_state}
  end

  def handle_cast(:raise, state) do
    raise RuntimeError, message: "Error, #{__MODULE__} #{state.id} has crashed"
  end

  def terminate(reason, state) do
    Logger.info("Exiting worker: #{__MODULE__} #{state.id} with reason: #{inspect(reason)}")
  end

  ## Private
  defp via_tuple(name),
    do: {:via, Registry, {@registry, name}}

  defp do_tick(state) do
    state =
      if state.input.left do
        %{state | x: state.x - 5}
      else
        state
      end

    state =
      if state.input.right do
        %{state | x: state.x + 5}
      else
        state
      end

    state =
      if state.input.up do
        %{state | y: state.y - 5}
      else
        state
      end

    state =
      if state.input.down do
        %{state | y: state.y + 5}
      else
        state
      end

    state
  end

  defp state_for_client(state) do
    %{x: state.x, y: state.y}
  end
end
