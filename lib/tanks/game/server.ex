defmodule Tanks.Game.Server do
  use GenServer
  require Logger

  @registry Registry.Tanks.Game.Server
  @tickms 16

  @initial_state %{
    game_id: nil,
    player_id: nil,
    tick: 0
  }

  @projectile_speed 10.0

  # API

  def start_link(game_id) do
    GenServer.start_link(__MODULE__, game_id, name: name(game_id))
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

  def send_input(game_id, input) do
    GenServer.cast(name(game_id), {:update_input, input})
  end

  def send_action(game_id, :fire, {x, y}) do
    GenServer.cast(name(game_id), {:action, :fire, {x, y}})
  end

  # Callbacks

  def init(game_id) do
    Logger.info("Starting game server #{__MODULE__} #{game_id}")

    Process.send_after(self(), :tick, @tickms)

    Tanks.GameECS.start(game_id)

    # player =
    #   Tanks.Game.Entity.Player.new()
    #   |> Tanks.Game.Ops.add_entity(game_id)

    # Enum.each(1..8, fn i ->
    #   Tanks.Game.Entity.Wall.new(150, 100 + i * 50)
    #   |> Tanks.Game.Ops.add_entity(game_id)
    # end)

    # Enum.each(1..8, fn i ->
    #   Tanks.Game.Entity.Wall.new(550, 100 + i * 50)
    #   |> Tanks.Game.Ops.add_entity(game_id)
    # end)

    # Tanks.Game.Entity.Zombie.new(250, 250)
    # |> Tanks.Game.Ops.add_entity(game_id)

    # Tanks.Game.Entity.Zombie.new(270, 250)
    # |> Tanks.Game.Ops.add_entity(game_id)

    # Tanks.Game.Entity.Zombie.new(250, 270)
    # |> Tanks.Game.Ops.add_entity(game_id)

    # Tanks.Game.Entity.Zombie.new(290, 250)
    # |> Tanks.Game.Ops.add_entity(game_id)

    # Tanks.Game.Entity.Zombie.new(250, 290)
    # |> Tanks.Game.Ops.add_entity(game_id)

    # TODO: should use after_init
    # {:ok, %{@initial_state | game_id: game_id, player_id: player.id}}

    {:ok, %{@initial_state | game_id: game_id, player_id: 0}}
  end

  def handle_info(:tick, state) do
    start_ns = System.os_time(:nanosecond)

    new_state = do_tick(state)
    client_state = state_for_client(new_state)

    took_ns = System.os_time(:nanosecond) - start_ns
    took_ms = Float.round(took_ns / 1_000_000, 2)

    client_state =
      client_state
      |> Map.put(:stats, %{
        tick: state.tick,
        last_tick_ms: took_ms
      })

    # Logger.debug("Tick took #{round(took_ns / 1000)} μs")

    TanksWeb.Endpoint.broadcast!("game:#{state.game_id}", "tick", client_state)

    Process.send_after(self(), :tick, max(@tickms - round(took_ms), 0))

    {:noreply, new_state}
  end

  def handle_call(:state, _from, state) do
    {:reply, {:ok, state}, state}
  end

  def handle_call(:summary, _from, state) do
    full_state = state_for_client(state)

    stats = %{
      players_count: full_state.players |> Map.keys() |> length(),
      zombies_count: full_state.zombies |> Map.keys() |> length()
    }

    summary = Map.merge(state, stats)

    {:reply, {:ok, summary}, state}
  end

  def handle_cast({:update_input, input}, state) do
    event =
      Tanks.Game.Event.Control.new(
        Tanks.Game.Entity.Player,
        state.player_id,
        input
      )

    ECS.Queue.put(state.game_id, :input, event)

    {:noreply, state}
  end

  def handle_cast({:action, :fire, {velocity_x, velocity_y}}, state) do
    player = ECS.Registry.Entity.get(state.game_id, Tanks.Game.Entity.Player, state.player_id)
    %{x: player_x, y: player_y} = player.components.position.state

    Tanks.Game.Entity.Projectile.new(
      player_x,
      player_y,
      velocity_x * @projectile_speed,
      velocity_y * @projectile_speed,
      2000
    )
    |> Tanks.Game.Ops.add_entity(state.game_id)

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

  defp do_tick(%{tick: tick, game_id: game_id} = state) do
    process_input_events(game_id)

    Tanks.Game.Cache.Position.update(game_id)

    Tanks.Game.System.LifetimeDying.process(game_id)
    if rem(tick, 10) == 0, do: Tanks.Game.System.AI.process(game_id)
    Tanks.Game.System.Movement.process(game_id)
    Tanks.Game.System.Velocity.process(game_id)
    Tanks.Game.System.Collision.process(game_id)

    process_internal_events(game_id)

    %{state | tick: tick + 1}
  end

  defp state_for_client(%{game_id: game_id} = state) do
    player = ECS.Registry.Entity.get(game_id, Tanks.Game.Entity.Player, state.player_id)
    %{x: player_x, y: player_y} = player.components.position.state
    %{size: player_size} = player.components.size.state

    players = %{
      0 => %{
        x: player_x,
        y: player_y,
        size: player_size
      }
    }

    projectiles =
      ECS.Registry.Entity.all(game_id, Tanks.Game.Entity.Projectile)
      |> Enum.map(fn entity ->
        %{x: position_x, y: position_y} = entity.components.position.state
        %{size: size_size} = entity.components.size.state

        data = %{
          x: position_x,
          y: position_y,
          size: size_size
        }

        {entity.id, data}
      end)
      |> Map.new()

    walls =
      ECS.Registry.Entity.all(game_id, Tanks.Game.Entity.Wall)
      |> Enum.map(fn entity ->
        %{x: position_x, y: position_y} = entity.components.position.state
        %{size: size_size} = entity.components.size.state

        data = %{
          x: position_x,
          y: position_y,
          size: size_size
        }

        {entity.id, data}
      end)
      |> Map.new()

    zombies =
      ECS.Registry.Entity.all(game_id, Tanks.Game.Entity.Zombie)
      |> Enum.map(fn entity ->
        %{x: position_x, y: position_y} = entity.components.position.state
        %{size: size_size} = entity.components.size.state

        data = %{
          x: position_x,
          y: position_y,
          size: size_size
        }

        {entity.id, data}
      end)
      |> Map.new()

    %{
      game_id: state.game_id,
      players: players,
      projectiles: projectiles,
      walls: walls,
      zombies: zombies
    }
  end

  def process_input_events(game_id) do
    events = ECS.Queue.pop_all(game_id, :input) |> Enum.reverse()

    Enum.map(events, fn event ->
      Tanks.Game.EventProcessor.process_event(game_id, event)
    end)
  end

  def process_internal_events(game_id) do
    events = ECS.Queue.pop_all(game_id, :internal) |> Enum.reverse()

    Enum.map(events, fn event ->
      Tanks.Game.EventProcessor.process_event(game_id, event)
    end)
  end
end
