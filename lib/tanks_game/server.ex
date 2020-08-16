defmodule TanksGame.Server do
  use GenServer
  require Logger

  @registry :servers_registry
  @tickms 16

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

  # Callbacks

  def init(id) do
    Logger.info("Starting #{__MODULE__} #{id}")

    Process.send_after(self(), :tick, @tickms)

    state = %{id: id, x: 0, y: 0}
    {:ok, state}
  end

  def handle_info(:tick, state) do
    new_x =
      if state.x > 300 do
        0
      else
        state.x + 5
      end

    new_y =
      if state.y > 300 do
        0
      else
        state.y + 5
      end

    state = %{state | x: new_x, y: new_y}

    data = %{x: state.x, y: state.y}
    TanksWeb.Endpoint.broadcast!("game:#{state.id}", "tick", data)

    Process.send_after(self(), :tick, @tickms)
    {:noreply, state}
  end

  def handle_call(:state, _from, state) do
    {:reply, {:ok, state}, state}
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
end
