defmodule ECS.Entity do
  defstruct [:id, :components]

  def new(entity_module, components) do
    entity =
      struct(entity_module, %{
        id: ECS.Registry.Id.generate_id(),
        components: components
      })

    ECS.Registry.ComponentTuple.register_entity(entity)

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
end
