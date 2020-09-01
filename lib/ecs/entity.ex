defmodule ECS.Entity do
  defstruct [:id, :components]

  def new(entity_module, components) do
    entity =
      struct(entity_module, %{
        id: ECS.Registry.Id.generate_id(),
        components: components
      })

    ECS.Registry.ComponentTuple.put_entity(entity)
    ECS.Registry.Entity.put(entity)

    entity
  end

  def reload(%{components: components} = entity) do
    updated_components =
      Enum.map(components, fn {key, %{pid: pid} = component} ->
        {key, %{component | state: ECS.Component.get_state(pid)}}
      end)
      |> Map.new()

    %{entity | components: updated_components}
  end

  def destroy(%entity_type{components: components, id: id} = entity) do
    Enum.map(components, fn {_key, %component_type{pid: pid} = _component} ->
      ECS.Component.destroy(component_type, pid)
    end)

    ECS.Registry.ComponentTuple.remove_entity(entity)
    ECS.Registry.Entity.remove(entity_type, id)

    :ok
  end
end
