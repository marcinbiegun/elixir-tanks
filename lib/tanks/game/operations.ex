defmodule Tanks.Game.Operations do
  def move_to_nonblocking(game_id, x, y, entities) do
    entities =
      entities
      |> Enum.map(fn entity ->
        position = entity.components.position
        new_position_state = %{position.state | x: x, y: y}
        new_position = ECS.Component.update(position.pid, new_position_state)
        entity = %{entity | components: %{entity.components | position: new_position}}
        Tanks.Game.Cache.Position.update(game_id, entity)
        entity
      end)

    entities
    |> Enum.map(fn entity ->
      move_to_near_empty_location(game_id, entity)
    end)
  end

  def move_to_near_empty_location(
        game_id,
        %{components: %{position: position_comp, size: size_comp}} = entity
      ) do
    %{x: x, y: y} = position_comp.state
    %{shape: shape} = size_comp.state

    {:ok, {new_x, new_y}} = Tanks.Game.Cache.Position.closest_empty_place(game_id, x, y, shape)

    new_position_state = %{position_comp.state | x: new_x, y: new_y}
    new_position = ECS.Component.update(position_comp.pid, new_position_state)

    entity = %{entity | components: %{entity.components | position: new_position}}

    Tanks.Game.Cache.Position.update(game_id, entity)

    entity
  end
end
