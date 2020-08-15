defmodule TanksGame.Server do
  use GenServer

  @tickms 50

  defmodule State do
    defstruct x: nil, y: nil
  end

  # API

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def state() do
    GenServer.call(__MODULE__, :state)
  end

  # Callbacks

  def init(_args) do
    state = %State{x: 0, y: 0}

    # First tick
    Process.send_after(self(), :tick, @tickms)

    {:ok, state}
  end

  def handle_info(:tick, state) do
    game_id = "123"

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
    IO.inspect(data, label: "sending tick")
    TanksWeb.Endpoint.broadcast!("game:" <> game_id, "tick", data)

    Process.send_after(self(), :tick, @tickms)
    {:noreply, state}
  end

  def handle_call(:state, _from, state) do
    {:reply, {:ok, state}, state}
  end
end
