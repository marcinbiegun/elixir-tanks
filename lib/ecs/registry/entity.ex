defmodule ECS.Registry.Entity do
  @initial_state %{}

  def start(game_id) do
    Agent.start_link(fn -> @initial_state end, name: name(game_id))
  end

  def clear(game_id) do
    Agent.update(name(game_id), fn _state -> @initial_state end)
  end

  def put(game_id, %type{id: id} = entity) do
    Agent.update(name(game_id), fn state ->
      type_map =
        Map.get(state, type, %{})
        |> Map.put(id, pack(entity))

      Map.put(state, type, type_map)
    end)
  end

  def all(game_id) do
    Agent.get(name(game_id), fn state ->
      Enum.flat_map(state, fn {type, collection} ->
        Enum.map(collection, fn {id, packed} ->
          unpack(packed, type, id)
        end)
      end)
    end)
  end

  def all(game_id, type) do
    Agent.get(name(game_id), fn state ->
      Map.get(state, type, %{})
      |> Enum.map(fn {id, packed} ->
        unpack(packed, type, id)
      end)
    end)
  end

  def state(game_id) do
    Agent.get(name(game_id), fn state -> state end)
  end

  def get(game_id, type, id) do
    Agent.get(name(game_id), fn state ->
      Map.get(state, type, %{})
      |> Map.get(id)
      |> unpack(type, id)
    end)
  end

  def remove(game_id, type, id) do
    Agent.update(name(game_id), fn state ->
      {_removed, new_map} = Map.get(state, type, %{}) |> Map.pop(id)
      Map.put(state, type, new_map)
    end)
  end

  defp pack(%{components: components} = _entity) do
    components
    |> Enum.map(fn {key, %type{pid: pid}} ->
      {key, {type, pid}}
    end)
    |> Map.new()
  end

  defp unpack(nil, _type, _id), do: nil

  defp unpack(packed, type, id) do
    components =
      packed
      |> Enum.map(fn {key, {component_type, pid}} ->
        component_state = ECS.Component.get_state(pid)
        component = %{__struct__: component_type, pid: pid, state: component_state}
        {key, component}
      end)
      |> Map.new()

    struct(type, %{id: id, components: components})
  end

  defp name(game_id), do: {:via, Registry, {Registry.ECS.Registry.Entity, game_id}}
end
