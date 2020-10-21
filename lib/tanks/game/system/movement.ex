defmodule Tanks.Game.System.Movement do
  alias Tanks.Game.Components.Position
  alias Tanks.Game.Components.Control
  alias Tanks.Game.Components.Size

  @component_types [Control, Position, Size]
  def component_types, do: @component_types

  def process(game_id) do
    component_tuples(game_id)
    |> Enum.each(fn tuple -> dispatch(game_id, tuple, :move) end)
  end

  defp dispatch(game_id, {_entity_type, entity_id, {control_pid, position_pid, size_pid}}, :move) do
    position = ECS.Component.get_state(position_pid)
    %{size: size} = ECS.Component.get_state(size_pid)

    %{down: down, left: left, right: right, up: up, speed: speed} =
      ECS.Component.get_state(control_pid)

    new_position =
      position
      |> try_move(game_id, :down, down, speed, size, entity_id)
      |> try_move(game_id, :left, left, speed, size, entity_id)
      |> try_move(game_id, :right, right, speed, size, entity_id)
      |> try_move(game_id, :up, up, speed, size, entity_id)

    if position != new_position, do: ECS.Component.update(position_pid, new_position)
  end

  defp try_move(position, _game_id, _direction, false, _speed, _size, _entity_id), do: position
  defp try_move(position, _game_id, _direction, _move?, 0, _size, _entity_id), do: position

  defp try_move(position, game_id, :down, true, speed, size, entity_id) do
    new_position = %{position | y: position.y + speed}
    validate_position(game_id, position, new_position, size, entity_id)
  end

  defp try_move(position, game_id, :left, true, speed, size, entity_id) do
    new_position = %{position | x: position.x - speed}
    validate_position(game_id, position, new_position, size, entity_id)
  end

  defp try_move(position, game_id, :right, true, speed, size, entity_id) do
    new_position = %{position | x: position.x + speed}
    validate_position(game_id, position, new_position, size, entity_id)
  end

  defp try_move(position, game_id, :up, true, speed, size, entity_id) do
    new_position = %{position | y: position.y - speed}
    validate_position(game_id, position, new_position, size, entity_id)
  end

  defp validate_position(game_id, old_position, new_position, size, entity_id) do
    if Tanks.Game.Cache.Position.colliding_entities(
         game_id,
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

  defp component_tuples(game_id) do
    id = ECS.Registry.ComponentTuple.build_registry_id(@component_types)
    ECS.Registry.ComponentTuple.get(game_id, id)
  end
end
