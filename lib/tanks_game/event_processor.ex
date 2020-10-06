defmodule TanksGame.EventProcessor do
  require Logger

  def process_event(
        %TanksGame.Event.Control{entity_module: entity_module, entity_id: entity_id, data: data} =
          event
      ) do
    case ECS.Registry.Entity.get(entity_module, entity_id) do
      nil ->
        Logger.error(
          "Unable to process Control event, because entity #{entity_id} doesn't exist! Event: #{
            inspect(event)
          }"
        )

      entity ->
        entity.components.control.pid
        |> ECS.Component.update(data)
    end
  end

  def process_event(
        %TanksGame.Event.Destroy{entity_module: entity_module, entity_id: entity_id} = event
      ) do
    case ECS.Registry.Entity.get(entity_module, entity_id) do
      nil ->
        Logger.error(
          "Unable to process Destroy event, because entity #{entity_id} doesn't exist! Event: #{
            inspect(event)
          }"
        )

      entity ->
        ECS.Entity.destroy(entity)
    end
  end

  def process_event(event) do
    Logger.error("Can't process unknown event: #{inspect(event)}")
    {:error, :unknown_event}
  end
end
