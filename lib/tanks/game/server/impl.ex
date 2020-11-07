defmodule Tanks.Game.Server.Impl do
  @run_ai_system_every_tick 10

  def tick(game_id, tick) do
    start_ns = System.os_time(:nanosecond)

    do_tick(game_id, tick)
    client_state = build_client_state(game_id)

    took_ns = System.os_time(:nanosecond) - start_ns
    took_ms = Float.round(took_ns / 1_000_000, 2)

    client_state =
      client_state
      |> Map.put(:stats, %{
        tick: tick,
        last_tick_ms: took_ms
      })

    {:ok, client_state, took_ms}
  end

  def build_init_state(game_id) do
    tiles =
      case(ECS.Registry.Entity.all(game_id, Tanks.Game.Entity.Board) |> Enum.at(0)) do
        nil ->
          []

        board_entity ->
          board_entity.components.tiles.state.tiles
      end

    %{tiles: tiles}
  end

  def build_client_state(game_id) do
    players =
      ECS.Registry.Entity.all(game_id, Tanks.Game.Entity.Player)
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
        %{current: hp_current, max: hp_max} = entity.components.health.state

        data = %{
          x: position_x,
          y: position_y,
          size: size_size,
          hp_current: hp_current,
          hp_max: hp_max
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
      game_id: game_id,
      players: players,
      projectiles: projectiles,
      walls: walls,
      zombies: zombies
    }
  end

  defp do_tick(game_id, tick) do
    process_input_events(game_id)

    Tanks.Game.System.LifetimeDying.process(game_id)
    process_internal_events(game_id)

    Tanks.Game.Cache.Position.update(game_id)

    if rem(tick, @run_ai_system_every_tick) == 0, do: Tanks.Game.System.AI.process(game_id)
    Tanks.Game.System.Movement.process(game_id)
    Tanks.Game.System.Velocity.process(game_id)
    Tanks.Game.System.Collision.process(game_id)

    process_internal_events(game_id)

    Tanks.Game.System.HealthDying.process(game_id)

    process_internal_events(game_id)
  end

  defp process_input_events(game_id) do
    events = ECS.Queue.pop_all(game_id, :input) |> Enum.reverse()

    Enum.map(events, fn event ->
      Tanks.Game.EventProcessor.process_event(game_id, event)
    end)
  end

  defp process_internal_events(game_id) do
    events = ECS.Queue.pop_all(game_id, :internal) |> Enum.reverse()

    Enum.map(events, fn event ->
      Tanks.Game.EventProcessor.process_event(game_id, event)
    end)
  end
end
