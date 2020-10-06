defmodule TanksGame.System.Movement do
  alias TanksGame.Components.Position
  alias TanksGame.Components.Control
  alias TanksGame.Components.Size

  @component_types [Control, Position, Size]
  def component_types, do: @component_types

  def process do
    component_tuples()
    |> Enum.each(fn tuple -> dispatch(tuple, :move) end)
  end

  defp dispatch({_entity_type, entity_id, {control_pid, position_pid, size_pid}}, :move) do
    position = ECS.Component.get_state(position_pid)
    %{size: size} = ECS.Component.get_state(size_pid)

    %{down: down, left: left, right: right, up: up, speed: speed} =
      ECS.Component.get_state(control_pid)

    new_position =
      position
      |> try_move(:down, down, speed, size, entity_id)
      |> try_move(:left, left, speed, size, entity_id)
      |> try_move(:right, right, speed, size, entity_id)
      |> try_move(:up, up, speed, size, entity_id)

    if position != new_position, do: ECS.Component.update(position_pid, new_position)
  end

  defp try_move(position, _direction, false, _speed, _size, _entity_id), do: position
  defp try_move(position, _direction, _move?, 0, _size, _entity_id), do: position

  defp try_move(position, :down, true, speed, size, entity_id) do
    new_position = %{position | y: position.y + speed}
    validate_position(position, new_position, size, entity_id)
  end

  defp try_move(position, :left, true, speed, size, entity_id) do
    new_position = %{position | x: position.x - speed}
    validate_position(position, new_position, size, entity_id)
  end

  defp try_move(position, :right, true, speed, size, entity_id) do
    new_position = %{position | x: position.x + speed}
    validate_position(position, new_position, size, entity_id)
  end

  defp try_move(position, :up, true, speed, size, entity_id) do
    new_position = %{position | y: position.y - speed}
    validate_position(position, new_position, size, entity_id)
  end

  defp validate_position(old_position, new_position, size, entity_id) do
    if TanksGame.Cache.Position.colliding_entities(
         new_position.x,
         new_position.y,
         size,
         entity_id
       ) == [] do
      new_position
    else
      old_position
    end
  end

  defp component_tuples do
    ECS.Registry.ComponentTuple.build_registry_id(@component_types)
    |> ECS.Registry.ComponentTuple.get()
  end
end
