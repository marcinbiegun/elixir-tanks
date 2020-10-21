defmodule Tanks.Game.System.LifetimeDying do
  alias Tanks.Game.Components.Lifetime

  @component_types [Lifetime]
  def component_types, do: @component_types

  def process(game_id) do
    now_miliseconds = System.os_time(:millisecond)

    component_tuples(game_id)
    |> Enum.each(fn tuple -> dispatch(game_id, tuple, now_miliseconds) end)
  end

  defp dispatch(game_id, {entity_type, entity_id, {lifetime_pid}}, now_miliseconds) do
    lifetime = ECS.Component.get_state(lifetime_pid)

    if now_miliseconds >= lifetime.die_at do
      event = Tanks.Game.Event.Destroy.new(entity_type, entity_id)
      ECS.Queue.put(game_id, :internal, event)
    end
  end

  defp component_tuples(game_id) do
    id = ECS.Registry.ComponentTuple.build_registry_id(@component_types)
    ECS.Registry.ComponentTuple.get(game_id, id)
  end
end
