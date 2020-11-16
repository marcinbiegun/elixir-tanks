defmodule Tanks.Game.System.AI do
  alias Tanks.Game.Components.{Attack, Brain, Control, Position}
  alias Utils.Math

  @component_types [Attack, Brain, Control, Position]
  def component_types, do: @component_types

  def process(game_id) do
    component_tuples(game_id)
    |> Enum.each(fn tuple -> dispatch(game_id, tuple) end)
  end

  defp dispatch(
         game_id,
         {_entity_type, _entity_id, {attack_pid, brain_pid, control_pid, position_pid}}
       ) do
    position_state = ECS.Component.get_state(position_pid)
    brain_state = ECS.Component.get_state(brain_pid)

    # Update control
    players = ECS.Registry.Entity.all(game_id, Tanks.Game.Entity.Player)
    {nearest_player, nearest_player_distance} = nearest(position_state, players)

    control_state = ECS.Component.get_state(control_pid)

    new_control_state =
      if nearest_player_distance < brain_state.sight_range do
        control_state |> Map.merge(control_move_towards_player(position_state, nearest_player))
      else
        control_state |> Map.merge(control_wander())
      end

    ECS.Component.update(control_pid, new_control_state)

    # Try to attack
    attack_state = ECS.Component.get_state(attack_pid)
    now = System.os_time(:millisecond)

    if nearest_player != nil and now > attack_state.next_attack_at and
         nearest_player_distance < attack_state.range do
      new_attack_state = attack_state |> Map.merge(%{next_attack_at: now + attack_state.reload})
      ECS.Component.update(attack_pid, new_attack_state)

      hit_event =
        Tanks.Game.Event.Hit.new(
          Tanks.Game.Entity.Player,
          nearest_player.id
        )

      ECS.Queue.put(game_id, :internal, hit_event)
    end

    # Update brain.last_decision_at
    now = System.os_time(:millisecond)
    updated_brain_state = brain_state |> Map.put(:last_decision_at, now)
    ECS.Component.update(brain_pid, updated_brain_state)
  end

  defp control_move_towards_player(_position, nil) do
    %{down: false, left: false, right: false, up: false}
  end

  defp control_move_towards_player(%{x: x, y: y}, nearest_player) do
    %{x: px, y: py} = nearest_player.components.position.state

    left = px < x
    right = px > x

    down = py > y
    up = py < y

    %{down: down, left: left, right: right, up: up}
  end

  defp control_wander() do
    case Enum.random(0..6) do
      0 ->
        %{down: true, left: false, right: false, up: false}

      1 ->
        %{down: false, left: true, right: false, up: false}

      2 ->
        %{down: false, left: false, right: true, up: false}

      3 ->
        %{down: false, left: false, right: false, up: true}

      _ ->
        %{down: false, left: false, right: false, up: false}
    end
  end

  defp nearest(_position, []) do
    {nil, 0.0}
  end

  defp nearest(%{x: x, y: y}, players) do
    players
    |> Enum.map(fn player ->
      %{x: px, y: py} = player.components.position.state
      {player, Math.distance(x, y, px, py)}
    end)
    |> Enum.sort_by(fn {_player, distance} ->
      distance
    end)
    |> Enum.at(0)
  end

  defp component_tuples(game_id) do
    id = ECS.Registry.ComponentTuple.build_registry_id(@component_types)
    ECS.Registry.ComponentTuple.get(game_id, id)
  end
end
