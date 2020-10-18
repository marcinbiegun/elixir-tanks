defmodule Tanks.Game do
  @moduledoc """
  TanksGame module keeps game logic modules.
  """

  # TODO: Use registers https://hexdocs.pm/elixir/Registry.html
  # {:error, {:already_started, #PID<0.371.0>}}
  # {:ok, pid}
  def start(game_id) do
    start_registers(game_id)
    register_systems(game_id)

    start_queues(game_id)
    register_queues(game_id)

    start_caches(game_id)
    register_caches(game_id)
  end

  def reset(game_id) do
    clear_registers(game_id)
    register_systems(game_id)

    clear_queues(game_id)
    register_queues(game_id)

    clear_caches(game_id)
    register_caches(game_id)
  end

  defp start_registers(_game_id) do
    ECS.Registry.Component.start()
    ECS.Registry.ComponentTuple.start()
    ECS.Registry.Entity.start()
    ECS.Registry.Id.start()
  end

  defp clear_registers(_game_id) do
    ECS.Registry.Component.clear()
    ECS.Registry.ComponentTuple.clear()
    ECS.Registry.Entity.clear()
    ECS.Registry.Id.clear()
    ECS.Queue.clear()
  end

  defp register_systems(_game_id) do
    Tanks.Game.System.Velocity.component_types()
    |> ECS.Registry.ComponentTuple.build_registry_id()
    |> ECS.Registry.ComponentTuple.init_register_type()

    Tanks.Game.System.Movement.component_types()
    |> ECS.Registry.ComponentTuple.build_registry_id()
    |> ECS.Registry.ComponentTuple.init_register_type()

    Tanks.Game.System.LifetimeDying.component_types()
    |> ECS.Registry.ComponentTuple.build_registry_id()
    |> ECS.Registry.ComponentTuple.init_register_type()

    Tanks.Game.System.Collision.component_types()
    |> ECS.Registry.ComponentTuple.build_registry_id()
    |> ECS.Registry.ComponentTuple.init_register_type()

    Tanks.Game.System.AI.component_types()
    |> ECS.Registry.ComponentTuple.build_registry_id()
    |> ECS.Registry.ComponentTuple.init_register_type()
  end

  # Queues

  def start_queues(game_id) do
    ECS.Queue.start()
  end

  def clear_queues(game_id) do
    ECS.Queue.clear()
  end

  def register_queues(game_id) do
    ECS.Queue.register(:input)
    ECS.Queue.register(:output)
    ECS.Queue.register(:internal)
  end

  # Caches

  def start_caches(game_id) do
    ECS.Cache.start()
  end

  def clear_caches(game_id) do
    ECS.Cache.clear()
  end

  def register_caches(game_id) do
    Tanks.Game.Cache.Position
    |> ECS.Cache.register()

    Tanks.Game.Cache.Position.component_types()
    |> ECS.Registry.ComponentTuple.build_registry_id()
    |> ECS.Registry.ComponentTuple.init_register_type()
  end
end
