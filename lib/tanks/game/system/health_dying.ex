defmodule Tanks.Game.System.HealthDying do
  alias Tanks.Game.Components.Health

  @component_types [Health]
  def component_types, do: @component_types

  def process(game_id) do
    component_tuples(game_id)
    |> Enum.each(fn tuple -> dispatch(game_id, tuple) end)
  end

  defp dispatch(game_id, {entity_type, entity_id, {health_pid}}) do
    health = ECS.Component.get_state(health_pid)

    if health.hp <= 0 do
      event = Tanks.Game.Event.Destroy.new(entity_type, entity_id)
      ECS.Queue.put(game_id, :internal, event)
    end
  end

  defp component_tuples(game_id) do
    id = ECS.Registry.ComponentTuple.build_registry_id(@component_types)
    ECS.Registry.ComponentTuple.get(game_id, id)
  end
end
