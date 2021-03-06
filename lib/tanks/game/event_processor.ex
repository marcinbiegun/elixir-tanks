defmodule Tanks.Game.EventProcessor do
  require Logger

  def process_event(
        game_id,
        %Tanks.Game.Event.Control{entity_module: entity_module, entity_id: entity_id, data: data} =
          event
      ) do
    case ECS.Registry.Entity.get(game_id, entity_module, entity_id) do
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
        game_id,
        %Tanks.Game.Event.Hit{entity_module: entity_module, entity_id: entity_id, data: _data} =
          event
      ) do
    case ECS.Registry.Entity.get(game_id, entity_module, entity_id) do
      nil ->
        Logger.error(
          "Unable to process Hit event, because entity #{entity_id} doesn't exist! Event: #{
            inspect(event)
          }"
        )

      entity ->
        health = entity.components.health
        new_state = %{health.state | current: health.state.current - 1}
        ECS.Component.update(health.pid, new_state)
    end
  end

  def process_event(
        game_id,
        %Tanks.Game.Event.Destroy{entity_module: entity_module, entity_id: entity_id} = event
      ) do
    case ECS.Registry.Entity.get(game_id, entity_module, entity_id) do
      nil ->
        Logger.error(
          "Unable to process Destroy event, because entity #{entity_id} doesn't exist! Event: #{
            inspect(event)
          }"
        )

      entity ->
        Tanks.GameECS.remove_entity(entity, game_id)

        # Projectile destroyed effect
        if entity_module == Tanks.Game.Entity.Projectile do
          effect_event =
            Tanks.Game.Event.Effect.new(
              Tanks.Game.Entity.Projectile,
              entity.id,
              %{type: "hit"}
            )

          ECS.Queue.put(game_id, :output, effect_event)
        end
    end
  end

  def process_event(game_id, event) do
    Logger.error("Can't process unknown event for game_id #{game_id}: #{inspect(event)}")
    {:error, :unknown_event}
  end
end
