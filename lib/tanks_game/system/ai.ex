defmodule TanksGame.System.AI do
  alias TanksGame.Components.{Brain, Control}

  @component_types [Brain, Control]
  def component_types, do: @component_types

  def process do
    component_tuples()
    |> Enum.each(fn tuple -> dispatch(tuple) end)
  end

  defp dispatch({_entity_type, _entity_id, {brain_pid, control_pid}}) do
    if Enum.random(0..1) == 0 do
      brain_state = ECS.Component.get_state(brain_pid)
      now = System.os_time(:millisecond)
      updated_brain_state = brain_state |> Map.put(:last_decision_at, now)
      ECS.Component.update(brain_pid, updated_brain_state)

      control_state = ECS.Component.get_state(control_pid)
      updated_control_state = control_state |> Map.merge(random_control())
      ECS.Component.update(control_pid, updated_control_state)
    end
  end

  defp component_tuples do
    ECS.Registry.ComponentTuple.build_registry_id(@component_types)
    |> ECS.Registry.ComponentTuple.get()
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
end
