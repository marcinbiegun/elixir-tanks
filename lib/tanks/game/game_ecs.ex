defmodule Tanks.GameECS do
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

  defp start_registers(game_id) do
    ECS.Registry.Component.start(game_id)
    ECS.Registry.ComponentTuple.start(game_id)
    ECS.Registry.Entity.start(game_id)
  end

  defp clear_registers(game_id) do
    ECS.Registry.Component.clear(game_id)
    ECS.Registry.ComponentTuple.clear(game_id)
    ECS.Registry.Entity.clear(game_id)
    ECS.Queue.clear(game_id)
  end

  defp register_systems(game_id) do
    reg_id =
      Tanks.Game.System.Velocity.component_types()
      |> ECS.Registry.ComponentTuple.build_registry_id()

    ECS.Registry.ComponentTuple.init_register_type(game_id, reg_id)

    reg_id =
      Tanks.Game.System.Movement.component_types()
      |> ECS.Registry.ComponentTuple.build_registry_id()

    ECS.Registry.ComponentTuple.init_register_type(game_id, reg_id)

    reg_id =
      Tanks.Game.System.LifetimeDying.component_types()
      |> ECS.Registry.ComponentTuple.build_registry_id()

    ECS.Registry.ComponentTuple.init_register_type(game_id, reg_id)

    reg_id =
      Tanks.Game.System.Collision.component_types()
      |> ECS.Registry.ComponentTuple.build_registry_id()

    ECS.Registry.ComponentTuple.init_register_type(game_id, reg_id)

    reg_id =
      Tanks.Game.System.AI.component_types()
      |> ECS.Registry.ComponentTuple.build_registry_id()

    ECS.Registry.ComponentTuple.init_register_type(game_id, reg_id)
  end

  # Queues

  def start_queues(game_id) do
    ECS.Queue.start(game_id)
  end

  def clear_queues(game_id) do
    ECS.Queue.clear(game_id)
  end

  def register_queues(game_id) do
    ECS.Queue.register(game_id, :input)
    ECS.Queue.register(game_id, :output)
    ECS.Queue.register(game_id, :internal)
  end

  # Caches

  def start_caches(game_id) do
    ECS.Cache.start(game_id)
  end

  def clear_caches(game_id) do
    ECS.Cache.clear(game_id)
  end

  def register_caches(game_id) do
    ECS.Cache.register(game_id, Tanks.Game.Cache.Position)

    reg_id =
      Tanks.Game.Cache.Position.component_types()
      |> ECS.Registry.ComponentTuple.build_registry_id()

    ECS.Registry.ComponentTuple.init_register_type(game_id, reg_id)
  end
end
