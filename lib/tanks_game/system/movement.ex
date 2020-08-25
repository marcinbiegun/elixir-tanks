defmodule TanksGame.System.Movement do
  alias TanksGame.Components.Position
  alias TanksGame.Components.Control

  @component_types [Control, Position]
  def component_types, do: @component_types

  def process do
    component_tuples()
    |> Enum.each(fn tuple -> dispatch(tuple, :move) end)
  end

  defp dispatch({control_pid, position_pid}, :move) do
    position = ECS.Component.get_state(position_pid)

    %{down: down, left: left, right: right, up: up, speed: speed} =
      ECS.Component.get_state(control_pid)

    if speed > 0 and (down == true or left == true or right == true or up == true) do
      update_position_component(position_pid, position, %{
        down: down,
        left: left,
        right: right,
        up: up,
        speed: speed
      })
    end
  end

  defp update_position_component(position_pid, position, %{
         down: down,
         left: left,
         right: right,
         up: up,
         speed: speed
       }) do
    position =
      if left do
        %{position | x: position.x - speed}
      else
        position
      end

    position =
      if right do
        %{position | x: position.x + speed}
      else
        position
      end

    position =
      if up do
        %{position | y: position.y - speed}
      else
        position
      end

    position =
      if down do
        %{position | y: position.y + speed}
      else
        position
      end

    ECS.Component.update(position_pid, position)
  end

  defp component_tuples do
    ECS.Registry.ComponentTuple.build_registry_id(@component_types)
    |> ECS.Registry.ComponentTuple.get()
  end
end
