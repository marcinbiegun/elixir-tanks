defmodule TanksGame.EventProcessor do
  def process_event(
        %TanksGame.Event.Control{entity_module: entity_module, entity_id: entity_id, data: data} =
          _event
      ) do
    entity = ECS.Registry.Entity.get(entity_module, entity_id)

    entity.components.control.pid
    |> ECS.Component.update(data)
  end

  def process_event(
        %TanksGame.Event.Destroy{entity_module: entity_module, entity_id: entity_id} = _event
      ) do
    entity = ECS.Registry.Entity.get(entity_module, entity_id)
    ECS.Entity.destroy(entity)
  end

  def process_event(_event) do
    :unknown_event
  end
end
