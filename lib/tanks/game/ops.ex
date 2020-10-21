defmodule Tanks.Game.Ops do
  @moduledoc """
  Note: there is add_component, compoennts to work winith a game needs
  the be added to an entity, then they can be registered
  """
  def add_entity(entity, game_id) do
    ECS.Registry.ComponentTuple.put_entity(game_id, entity)
    ECS.Registry.Entity.put(game_id, entity)

    entity.components
    |> Enum.each(fn {_key, component} ->
      ECS.Registry.Component.put(game_id, component.__struct__, component.pid)
    end)

    entity
  end

  def remove_entity(entity, game_id) do
    ECS.Registry.ComponentTuple.remove_entity(game_id, entity)
    ECS.Registry.Entity.remove(game_id, entity.__struct__, entity.id)

    entity.components
    |> Enum.each(fn {_key, component} ->
      ECS.Registry.Component.remove(game_id, component.__struct__, component.pid)
      ECS.Component.Agent.stop(component.pid)
    end)

    entity
  end
end
