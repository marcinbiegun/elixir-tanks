defmodule TanksGame.System.Collision do
  alias TanksGame.Components.Position
  alias TanksGame.Components.Size

  @component_types [Size, Position]
  def component_types, do: @component_types

  def process do
    component_tuples()
    |> Enum.each(fn tuple -> build(tuple, :move) end)
    |> detect()
  end

  defp build({entity_type, entity_id, {size_pid, position_pid}}, :move) do
    position = ECS.Component.get_state(position_pid)
    size = ECS.Component.get_state(size_pid)

    {entity_type, entity_id, position.x, position.y, size}
  end

  defp detect(collidables) do
    for obj <- collidables, other_obj <- collidables do
      IO.inspect(obj)
    end
  end

  defp component_tuples do
    ECS.Registry.ComponentTuple.build_registry_id(@component_types)
    |> ECS.Registry.ComponentTuple.get()
  end
end
