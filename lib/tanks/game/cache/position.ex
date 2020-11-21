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
        opts \\ []
      ) do
    filter_id_not = Keyword.get(opts, :id_not, nil)
    filter_type = Keyword.get(opts, :type, nil)
    filter_blocking = Keyword.get(opts, :blocking, nil)

    ECS.Cache.get(game_id, __MODULE__)
    # Filters
    |> Enum.filter(fn {_x, _y, _shape, _blocking, _entity_type, entity_id} ->
      filter_id_not == nil or entity_id != filter_id_not
    end)
    |> Enum.filter(fn {_x, _y, _shape, _blocking, entity_type, _entity_id} ->
      filter_type == nil or filter_type == entity_type
    end)
    |> Enum.filter(fn {_x, _y, _shape, blocking, _entity_type, _entity_id} ->
      filter_blocking == nil or filter_blocking == blocking
    end)
    # Find collisions
    |> Enum.filter(fn {x, y, shape, _blocking, _entity_type, _entity_id} ->
      Utils.Math.collision?(x, y, shape, check_x, check_y, check_shape)
    end)
    # Add distance
    |> Enum.map(fn {x, y, shape, blocking, entity_type, entity_id} ->
      {x, y, shape, blocking, entity_type, entity_id, Utils.Math.distance(x, y, check_x, check_y)}
    end)
    # Sort by distance
    |> Enum.sort_by(fn {_x, _y, _shape, _blocking, _entity_type, _entity_id, distance} ->
      distance
    end)
    # Format result
    |> Enum.map(fn {_x, _y, _shape, _blocking, entity_type, entity_id, _distance} ->
      {entity_type, entity_id}
    end)
  end

  defp put_entity(game_id, {entity_type, entity_id, {position_pid, size_pid}}) do
    %{x: x, y: y} = ECS.Component.get_state(position_pid)
    %{shape: shape, blocking: blocking} = ECS.Component.get_state(size_pid)
    elem = {x, y, shape, blocking, entity_type, entity_id}

    ECS.Cache.update(game_id, __MODULE__, fn state ->
      [elem | state]
    end)
  end

  defp component_tuples(game_id) do
    id = ECS.Registry.ComponentTuple.build_registry_id(@component_types)
    ECS.Registry.ComponentTuple.get(game_id, id)
  end
end
