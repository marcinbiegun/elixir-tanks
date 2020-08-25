defmodule ECS.Registry.ComponentTuple do
  @tuple_id_separator ":"

  def register_system(system_module) do
    system_module.component_types()
    |> build_registry_id()
    |> init_register_type()
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

  def registered_ids() do
    Agent.get(__MODULE__, fn state -> Map.keys(state) end)
  end

  def registered_component_tuples() do
    Agent.get(__MODULE__, fn state -> Map.keys(state) |> Enum.map(&unbuild_registry_id/1) end)
  end

  def init_register_type(registry_id) do
    Agent.update(__MODULE__, fn state ->
      new_list = Map.get(state, registry_id, [])
      Map.put(state, registry_id, new_list)
    end)
  end

  def register_entity(%{components: components} = _entity) do
    registered_ids()
    |> Enum.each(fn registry_id ->
      component_types = unbuild_registry_id(registry_id)

      # |> IO.inspect(label: "component_types")

      matching_components = select_matching_components(component_types, components)

      # |> IO.inspect(label: "matching_components")

      matching_components_types =
        matching_components
        |> Enum.map(& &1.__struct__)

      # |> IO.inspect(label: "matching_component_types")

      if component_types == matching_components_types do
        # IO.puts("YES registering entity for #{registry_id}")
        put(registry_id, Enum.map(matching_components, & &1.pid) |> List.to_tuple())
      else
        nil
        # IO.puts("NOT registering entity for #{registry_id}")
      end
    end)
  end

  def entity_components_matching?(registry_id, components) do
    component_types = components |> Enum.map(& &1.__struct__)

    unbuild_registry_id(registry_id)
    Enum.all?(fn component_type -> component_type in component_types end)
  end

  def select_matching_components(component_types, components_map) do
    Enum.filter(components_map, fn {_key, component} ->
      component.__struct__ in component_types
    end)
    |> Enum.map(fn {_key, component} -> component end)
  end

  def start() do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def put(registry_id, component_pids_tuple)
      when is_atom(registry_id) and is_tuple(component_pids_tuple) do
    Agent.update(__MODULE__, fn state ->
      new_list = Map.get(state, registry_id, []) ++ [component_pids_tuple]
      Map.put(state, registry_id, new_list)
    end)
  end

  def get(registry_id) do
    Agent.get(__MODULE__, fn state -> Map.get(state, registry_id, []) end)
  end

  def state do
    Agent.get(__MODULE__, fn state -> state end)
  end
end
