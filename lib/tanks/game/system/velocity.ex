defmodule Tanks.Game.System.Velocity do
  alias Tanks.Game.Components.Position
  alias Tanks.Game.Components.Velocity

  @component_types [Position, Velocity]
  def component_types, do: @component_types

  def process do
    component_tuples()
    |> Enum.each(fn tuple -> dispatch(tuple, :move) end)
  end

  defp dispatch({_entity_type, _entity_id, {position_pid, velocity_pid}}, :move) do
    %{x: pos_x, y: pos_y} = ECS.Component.get_state(position_pid)
    %{x: vel_x, y: vel_y} = ECS.Component.get_state(velocity_pid)

    if vel_x != 0 or vel_y != 0 do
      new_position = %{x: pos_x + vel_x, y: pos_y + vel_y}
      ECS.Component.update(position_pid, new_position)
    end
  end

  defp component_tuples do
    ECS.Registry.ComponentTuple.build_registry_id(@component_types)
    |> ECS.Registry.ComponentTuple.get()
  end
end
