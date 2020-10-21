defmodule ECS.Registry.ComponentTuple do
  @tuple_id_separator ":"
  @initial_state %{}

  def start(game_id) do
    Agent.start_link(fn -> @initial_state end, name: name(game_id))
  end

  def clear(game_id) do
    Agent.update(name(game_id), fn _state -> @initial_state end)
  end

  def register_system(game_id, system_module) do
    system_module.component_types()
    |> build_registry_id()
    |> init_register_type(game_id)
  end

  def registered_ids(game_id) do
    Agent.get(name(game_id), fn state -> Map.keys(state) end)
  end

  def registered_component_tuples(game_id) do
    Agent.get(name(game_id), fn state -> Map.keys(state) |> Enum.map(&unbuild_registry_id/1) end)
  end

  def init_register_type(game_id, registry_id) do
    Agent.update(name(game_id), fn state ->
      new_list = Map.get(state, registry_id, [])
      Map.put(state, registry_id, new_list)
    end)
  end

  def put_entity(game_id, %entity_type{components: components, id: id} = _entity) do
    registered_ids(game_id)
    |> Enum.each(fn registry_id ->
      component_types = unbuild_registry_id(registry_id)

      matching_components = select_matching_components(component_types, components)

      matching_components_types =
        matching_components
        |> Enum.map(& &1.__struct__)

      if component_types == matching_components_types do
        put(
          game_id,
          registry_id,
          entity_type,
          id,
          Enum.map(matching_components, & &1.pid) |> List.to_tuple()
        )
      else
        nil
      end
    end)
  end

  def remove_entity(game_id, %_entity_type{components: _components, id: id} = _entity) do
    registered_ids(game_id)
    |> Enum.each(fn registry_id ->
      remove(game_id, registry_id, id)
    end)
  end

  def entity_components_matching?(registry_id, components) do
    component_types = components |> Enum.map(& &1.__struct__)

    unbuild_registry_id(registry_id)
    Enum.all?(fn component_type -> component_type in component_types end)
  end

  def put(game_id, registry_id, entity_type, entity_id, component_pids_tuple)
      when is_atom(registry_id) and is_integer(entity_id) and is_tuple(component_pids_tuple) do
    Agent.update(name(game_id), fn state ->
      new_list =
        Map.get(state, registry_id, []) ++ [{entity_type, entity_id, component_pids_tuple}]

      Map.put(state, registry_id, new_list)
    end)
  end

  def remove(game_id, registry_id, entity_id) do
    Agent.update(name(game_id), fn state ->
      new_list =
        Map.get(state, registry_id, [])
        |> Enum.filter(fn {_entity_type, stored_entity_id, _component_pids_tuple} ->
          stored_entity_id != entity_id
        end)

      Map.put(state, registry_id, new_list)
    end)
  end

  def get(game_id, registry_id) do
    Agent.get(name(game_id), fn state -> Map.get(state, registry_id, []) end)
  end

  def state(game_id) do
    Agent.get(name(game_id), fn state -> state end)
  end

  def build_registry_id(modules) do
    modules |> Enum.sort() |> Enum.join(@tuple_id_separator) |> String.to_atom()
  end

  def unbuild_registry_id(registry_id) do
    registry_id
    |> Atom.to_string()
    |> String.split(@tuple_id_separator)
    |> Enum.map(&String.to_atom/1)
  end

  defp select_matching_components(component_types, components_map) do
    Enum.filter(components_map, fn {_key, component} ->
      component.__struct__ in component_types
    end)
    |> Enum.map(fn {_key, component} -> component end)
  end

  defp name(game_id), do: {:via, Registry, {Registry.ECS.Registry.ComponentTuple, game_id}}
end
