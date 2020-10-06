defmodule TanksGame.Cache.Position do
  alias TanksGame.Components.Position
  alias TanksGame.Components.Size
  alias :math, as: Math

  @component_types [Position, Size]
  def component_types, do: @component_types

  @initial_state []
  def initial_state, do: @initial_state

  defp component_tuples do
    ECS.Registry.ComponentTuple.build_registry_id(@component_types)
    |> ECS.Registry.ComponentTuple.get()
  end

  def update do
    ECS.Cache.clear(__MODULE__)

    component_tuples()
    |> Enum.map(&put_entity/1)
  end

  defp put_entity({entity_type, entity_id, {position_pid, size_pid}}) do
    %{x: x, y: y} = ECS.Component.get_state(position_pid)
    %{size: size} = ECS.Component.get_state(size_pid)
    elem = {x, y, size, entity_type, entity_id}

    ECS.Cache.update(__MODULE__, fn state ->
      [elem | state]
    end)
  end

  # API
  def colliding_entities(check_x, check_y, check_size, self_entity_id \\ -1) do
    ECS.Cache.get(__MODULE__)
    |> Enum.filter(fn {_x, _y, _size, _entity_type, entity_id} ->
      entity_id != self_entity_id
    end)
    |> Enum.filter(fn {x, y, size, _entity_type, _entity_id} ->
      distance = Math.sqrt(Math.pow(x - check_x, 2) + Math.pow(y - check_y, 2))
      distance < size / 2 + check_size / 2
    end)
    |> Enum.map(fn {_x, _y, _size, entity_type, entity_id} ->
      {entity_type, entity_id}
    end)
  end
end
