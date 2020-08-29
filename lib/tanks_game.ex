defmodule TanksGame do
  @moduledoc """
  TanksGame module keeps game logic modules.
  """

  def start do
    start_registers()
    register_systems()
  end

  def reset do
    clear_registers()
    register_systems()
  end

  defp start_registers() do
    ECS.Registry.Component.start()
    ECS.Registry.ComponentTuple.start()
    ECS.Registry.Entity.start()
    ECS.Registry.Id.start()
  end

  defp clear_registers() do
    ECS.Registry.Component.clear()
    ECS.Registry.ComponentTuple.clear()
    ECS.Registry.Entity.clear()
    ECS.Registry.Id.clear()
  end

  defp register_systems() do
    TanksGame.System.Velocity.component_types()
    |> ECS.Registry.ComponentTuple.build_registry_id()
    |> ECS.Registry.ComponentTuple.init_register_type()

    TanksGame.System.Movement.component_types()
    |> ECS.Registry.ComponentTuple.build_registry_id()
    |> ECS.Registry.ComponentTuple.init_register_type()
  end
end
