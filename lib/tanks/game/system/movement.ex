defmodule Tanks.Game.System.Movement do
  alias Tanks.Game.Components.Position
  alias Tanks.Game.Components.Control
  alias Tanks.Game.Components.Size

  # TODO: move to config module
  @board_entity_type Tanks.Game.Entity.Board
  @board_tile_size 32
  @board_collidables [:wall]

  @component_types [Control, Position, Size]
  def component_types, do: @component_types

  def process(game_id) do
    component_tuples(game_id)
    |> Enum.each(fn tuple -> dispatch(game_id, tuple, :move) end)
  end

  defp dispatch(game_id, {_entity_type, entity_id, {control_pid, position_pid, size_pid}}, :move) do
    position = ECS.Component.get_state(position_pid)
    %{shape: shape} = ECS.Component.get_state(size_pid)

    %{down: down, left: left, right: right, up: up, speed: speed} =
      ECS.Component.get_state(control_pid)

    boards = ECS.Registry.Entity.all(game_id, @board_entity_type)

    new_position =
      position
      |> try_move(game_id, boards, :down, down, speed, shape, entity_id)
      |> try_move(game_id, boards, :left, left, speed, shape, entity_id)
      |> try_move(game_id, boards, :right, right, speed, shape, entity_id)
      |> try_move(game_id, boards, :up, up, speed, shape, entity_id)

    if position != new_position, do: ECS.Component.update(position_pid, new_position)
  end

  defp try_move(position, _game_id, _boards, _direction, false, _speed, _shape, _entity_id),
    do: position

  defp try_move(position, _game_id, _boards, _direction, _move?, 0, _shape, _entity_id),
    do: position

  defp try_move(position, game_id, boards, :down, true, speed, shape, entity_id) do
    new_position = %{position | y: position.y + speed}
    validate_position(game_id, boards, position, new_position, shape, entity_id)
  end

  defp try_move(position, game_id, boards, :left, true, speed, shape, entity_id) do
    new_position = %{position | x: position.x - speed}
    validate_position(game_id, boards, position, new_position, shape, entity_id)
  end

  defp try_move(position, game_id, boards, :right, true, speed, shape, entity_id) do
    new_position = %{position | x: position.x + speed}
    validate_position(game_id, boards, position, new_position, shape, entity_id)
  end

  defp try_move(position, game_id, boards, :up, true, speed, shape, entity_id) do
    new_position = %{position | y: position.y - speed}
    validate_position(game_id, boards, position, new_position, shape, entity_id)
  end

  defp validate_position(game_id, boards, old_position, new_position, shape, entity_id) do
    cond do
      Tanks.Game.Cache.Position.colliding_entities(
        game_id,
        new_position.x,
        new_position.y,
        shape,
        entity_id
      ) != [] ->
        old_position

      boards_collision?(boards, new_position, shape) == true ->
        old_position

      true ->
        new_position
    end
  end

  defp boards_collision?(boards, new_position, shape) do
    Enum.any?(boards, &board_collision?(&1, new_position, shape))
  end

  defp board_collision?(board, new_position, shape) do
    tiles = board.components.tiles.state.tiles

    Utils.TilesComp.collides?(
      tiles,
      @board_tile_size,
      @board_collidables,
      new_position.x,
      new_position.y,
      shape
    )
  end

  defp component_tuples(game_id) do
    id = ECS.Registry.ComponentTuple.build_registry_id(@component_types)
    ECS.Registry.ComponentTuple.get(game_id, id)
  end
end
