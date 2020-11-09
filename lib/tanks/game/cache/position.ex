defmodule Tanks.Game.Cache.Position do
  alias Tanks.Game.Components.Position
  alias Tanks.Game.Components.Size

  @component_types [Position, Size]
  def component_types, do: @component_types

  @initial_state []
  def initial_state, do: @initial_state

  @doc """
  Rebuilds the cache.
  """
  def update(game_id) do
    ECS.Cache.clear(game_id, __MODULE__)

    component_tuples(game_id)
    |> Enum.map(&put_entity(game_id, &1))
  end

  def colliding_entities(
        game_id,
        check_x,
        check_y,
        check_shape,
        entity_id_filter \\ -1,
        entity_type_filter \\ nil
      ) do
    ECS.Cache.get(game_id, __MODULE__)
    |> Enum.filter(fn {_x, _y, _shape, _entity_type, entity_id} ->
      entity_id != entity_id_filter
    end)
    |> Enum.filter(fn {_x, _y, _shape, entity_type, _entity_id} ->
      entity_type_filter == nil or entity_type_filter == entity_type
    end)
    |> Enum.map(fn {x, y, shape, entity_type, entity_id} ->
      {x, y, shape, entity_type, entity_id, Utils.Math.distance(x, y, check_x, check_y)}
    end)
    |> Enum.sort_by(fn {_x, _y, _shape, _entity_type, _entity_id, distance} ->
      distance
    end)
    |> Enum.filter(fn {x, y, shape, _entity_type, _entity_id, _distance} ->
      Utils.Math.collision?(x, y, shape, check_x, check_y, check_shape)
    end)
    |> Enum.map(fn {_x, _y, _shape, entity_type, entity_id, _distance} ->
      {entity_type, entity_id}
    end)
  end

  defp put_entity(game_id, {entity_type, entity_id, {position_pid, size_pid}}) do
    %{x: x, y: y} = ECS.Component.get_state(position_pid)
    %{shape: shape} = ECS.Component.get_state(size_pid)
    elem = {x, y, shape, entity_type, entity_id}

    ECS.Cache.update(game_id, __MODULE__, fn state ->
      [elem | state]
    end)
  end

  defp component_tuples(game_id) do
    id = ECS.Registry.ComponentTuple.build_registry_id(@component_types)
    ECS.Registry.ComponentTuple.get(game_id, id)
  end
end
