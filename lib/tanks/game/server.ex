defmodule Tanks.Game.Server do
  use GenServer
  require Logger

  alias Tanks.Game.Server.Impl

  @registry Registry.Tanks.Game.Server
  @tickms 16

  @initial_state %{
    game_id: nil,
    tick: 0
  }

  # API

  def start_link(game_id, opts \\ []) do
    GenServer.start_link(__MODULE__, {game_id, opts}, name: name(game_id))
  end

  def state(game_id) do
    if game_id in game_ids() do
      GenServer.call(name(game_id), :state)
    else
      {:error, "not found"}
    end
  end

  def game_ids do
    Registry.select(@registry, [{{:"$1", :_, :_}, [], [:"$1"]}])
  end

  def summary(game_id) do
    if game_id in game_ids() do
      GenServer.call(name(game_id), :summary)
    else
      {:error, "not found"}
    end
  end

  def all_summaries do
    game_ids()
    |> Enum.map(fn game_id ->
      {:ok, summary} = summary(game_id)
      summary
    end)
  end

  def stop(game_id) do
    Tanks.GameECS.reset(game_id)
    GenServer.stop(name(game_id))
  end

  def crash(game_id) do
    GenServer.cast(name(game_id), :raise)
  end

  def send_input(game_id, player_id, input) do
    GenServer.cast(name(game_id), {:update_input, player_id, input})
  end

  def send_action(game_id, player_id, :fire, {x, y}) do
    GenServer.cast(name(game_id), {:action, player_id, :fire, {x, y}})
  end

  def join_player(game_id, token) do
    GenServer.call(name(game_id), {:join_player, token})
  end

  def spawn_level(game_id) do
    GenServer.call(name(game_id), {:spawn_level})
  end

  # Callbacks

  def init({game_id, opts}) do
    Logger.info("Starting game server #{__MODULE__} #{game_id} whith ipts #{inspect(opts)}")

    if Keyword.get(opts, :no_tick) != true do
      Process.send_after(self(), :tick, @tickms)
    end

    Tanks.GameECS.start(game_id)

    {:ok, %{@initial_state | game_id: game_id}}
  end

  def handle_info(:tick, %{game_id: game_id, tick: tick} = state) do
    {:ok, client_state, took_ms} = Impl.tick(game_id, tick)

    TanksWeb.Endpoint.broadcast!("game:#{state.game_id}", "tick", client_state)

    Process.send_after(self(), :tick, max(@tickms - round(took_ms), 0))

    {:noreply, %{state | tick: tick + 1}}
  end

  def handle_call({:spawn_level}, _from, %{game_id: game_id} = state) do
    Tanks.Game.Content.Level.create_level_entities()
    |> Enum.map(&Tanks.GameECS.add_entity(&1, game_id))

    {:reply, :ok, state}
  end

  def handle_call(:state, _from, state) do
    {:reply, {:ok, state}, state}
  end

  def handle_call(:summary, _from, %{game_id: game_id} = state) do
    client_state = Impl.build_client_state(game_id)

    stats = %{
      players_count: client_state.players |> Map.keys() |> length(),
      zombies_count: client_state.zombies |> Map.keys() |> length()
    }

    summary = Map.merge(state, stats)

    {:reply, {:ok, summary}, state}
  end

  def handle_call({:join_player, player_token}, _from, %{game_id: game_id} = state) do
    player =
      Tanks.Game.Entity.Player.new()
      |> Tanks.GameECS.add_entity(game_id)

    player = %{id: player.id, token: player_token}

    {:reply, {:ok, player}, state}
  end

  def handle_cast({:update_input, player_id, input}, %{game_id: game_id} = state) do
    event =
      Tanks.Game.Event.Control.new(
        Tanks.Game.Entity.Player,
        player_id,
        input
      )

    ECS.Queue.put(game_id, :input, event)

    {:noreply, state}
  end

  def handle_cast(
        {:action, player_id, :fire, {velocity_x, velocity_y}},
        %{game_id: game_id} = state
      ) do
    player = ECS.Registry.Entity.get(state.game_id, Tanks.Game.Entity.Player, player_id)
    %{x: player_x, y: player_y} = player.components.position.state

    Tanks.Game.Content.Weapon.fire_projectile(player_x, player_y, velocity_x, velocity_y)
    |> Tanks.GameECS.add_entity(game_id)

    {:noreply, state}
  end

  def handle_cast(:raise, state) do
    raise RuntimeError, message: "Error, #{__MODULE__} #{state.game_id} has crashed"
  end

  def terminate(reason, state) do
    Logger.info("Exiting worker: #{__MODULE__} #{state.game_id} with reason: #{inspect(reason)}")
  end

  ## Private

  defp name(game_id), do: {:via, Registry, {@registry, game_id}}
end
