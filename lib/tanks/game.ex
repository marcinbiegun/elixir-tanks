defmodule Tanks.Game do
  @moduledoc """
  TanksGame module keeps game logic modules.
  """

  def start do
    start_registers()
    register_systems()

    start_queues()
    register_queues()

    start_caches()
    register_caches()
  end

  def reset do
    clear_registers()
    register_systems()

    clear_queues()
    register_queues()

    clear_caches()
    register_caches()
  end

  defp start_registers do
    ECS.Registry.Component.start()
    ECS.Registry.ComponentTuple.start()
    ECS.Registry.Entity.start()
    ECS.Registry.Id.start()
  end

  defp clear_registers do
    ECS.Registry.Component.clear()
    ECS.Registry.ComponentTuple.clear()
    ECS.Registry.Entity.clear()
    ECS.Registry.Id.clear()
    ECS.Queue.clear()
  end

  defp register_systems do
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

  def start_queues() do
    ECS.Queue.start()
  end

  def clear_queues() do
    ECS.Queue.clear()
  end

  def register_queues() do
    ECS.Queue.register(:input)
    ECS.Queue.register(:output)
    ECS.Queue.register(:internal)
  end

  # Caches

  def start_caches() do
    ECS.Cache.start()
  end

  def clear_caches() do
    ECS.Cache.clear()
  end

  def register_caches() do
    Tanks.Game.Cache.Position
    |> ECS.Cache.register()

    Tanks.Game.Cache.Position.component_types()
    |> ECS.Registry.ComponentTuple.build_registry_id()
    |> ECS.Registry.ComponentTuple.init_register_type()
  end
end
