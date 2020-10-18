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
    GenServer.call(name(game_id), :state)
  end

  def stop(game_id) do
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
    Logger.info("Starting #{__MODULE__} #{game_id}")

    Process.send_after(self(), :tick, @tickms)

    player = Tanks.Game.Entity.Player.new()

    Enum.each(1..8, fn i ->
      Tanks.Game.Entity.Wall.new(150, 100 + i * 50)
    end)

    Enum.each(1..8, fn i ->
      Tanks.Game.Entity.Wall.new(550, 100 + i * 50)
    end)

    Tanks.Game.Entity.Zombie.new(250, 250)
    Tanks.Game.Entity.Zombie.new(270, 250)
    Tanks.Game.Entity.Zombie.new(250, 270)
    Tanks.Game.Entity.Zombie.new(290, 250)
    Tanks.Game.Entity.Zombie.new(250, 290)

    {:ok, %{@initial_state | game_id: game_id, player_id: player.id}}
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

  def handle_cast({:update_input, input}, state) do
    event = Tanks.Game.Event.Control.new(Tanks.Game.Entity.Player, state.player_id, input)
    ECS.Queue.put(:input, event)

    {:noreply, state}
  end

  def handle_cast({:action, :fire, {velocity_x, velocity_y}}, state) do
    player = ECS.Registry.Entity.get(Tanks.Game.Entity.Player, state.player_id)
    %{x: player_x, y: player_y} = player.components.position.state

    Tanks.Game.Entity.Projectile.new(
      player_x,
      player_y,
      velocity_x * @projectile_speed,
      velocity_y * @projectile_speed,
      2000
    )

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

  defp do_tick(%{tick: tick} = state) do
    process_input_events()

    Tanks.Game.Cache.Position.update()

    Tanks.Game.System.LifetimeDying.process()
    if rem(tick, 10) == 0, do: Tanks.Game.System.AI.process()
    Tanks.Game.System.Movement.process()
    Tanks.Game.System.Velocity.process()
    Tanks.Game.System.Collision.process()

    process_internal_events()

    %{state | tick: tick + 1}
  end

  defp state_for_client(state) do
    player = ECS.Registry.Entity.get(Tanks.Game.Entity.Player, state.player_id)
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
      ECS.Registry.Entity.all(Tanks.Game.Entity.Projectile)
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
      ECS.Registry.Entity.all(Tanks.Game.Entity.Wall)
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
      ECS.Registry.Entity.all(Tanks.Game.Entity.Zombie)
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

    %{players: players, projectiles: projectiles, walls: walls, zombies: zombies}
  end

  def process_input_events() do
    events = ECS.Queue.pop_all(:input) |> Enum.reverse()

    Enum.map(events, fn event ->
      Tanks.Game.EventProcessor.process_event(event)
    end)
  end

  def process_internal_events() do
    events = ECS.Queue.pop_all(:internal) |> Enum.reverse()

    Enum.map(events, fn event ->
      Tanks.Game.EventProcessor.process_event(event)
    end)
  end
end
