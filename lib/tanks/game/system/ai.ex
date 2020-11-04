defmodule Tanks.Game.System.AI do
  alias Tanks.Game.Components.{Brain, Control, Position}
  alias Utils.Math

  @component_types [Brain, Control, Position]
  def component_types, do: @component_types

  def process(game_id) do
    component_tuples(game_id)
    |> Enum.each(fn tuple -> dispatch(game_id, tuple) end)
  end

  defp dispatch(game_id, {_entity_type, _entity_id, {brain_pid, control_pid, position_pid}}) do
    players = ECS.Registry.Entity.all(game_id, Tanks.Game.Entity.Player)

    # if Enum.random(0..1) == 0 do
    # Update brain.last_decision_at
    brain_state = ECS.Component.get_state(brain_pid)
    now = System.os_time(:millisecond)
    updated_brain_state = brain_state |> Map.put(:last_decision_at, now)
    ECS.Component.update(brain_pid, updated_brain_state)

    # Update control (movement direction)
    position_state = ECS.Component.get_state(position_pid)
    # control_state = ECS.Component.get_state(control_pid)

    # updated_control_state = control_state |> Map.merge(random_control())
    updated_control_state = move_towards_player(position_state, players)

    ECS.Component.update(control_pid, updated_control_state)
    # end
  end

  defp move_towards_player(_position, []) do
    %{down: false, left: false, right: false, up: false}
  end

  defp move_towards_player(%{x: x, y: y}, players) do
    closest_player =
      players
      |> Enum.sort_by(fn player ->
        %{x: px, y: py} = player.components.position.state
        Math.distance(x, y, px, py)
      end)
      |> Enum.at(0)

    %{x: px, y: py} = closest_player.components.position.state

    left = px < x
    right = px > x

    down = py > y
    up = py < y

    %{down: down, left: left, right: right, up: up}
  end

  defp random_control() do
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

  defp component_tuples(game_id) do
    id = ECS.Registry.ComponentTuple.build_registry_id(@component_types)
    ECS.Registry.ComponentTuple.get(game_id, id)
  end
end
