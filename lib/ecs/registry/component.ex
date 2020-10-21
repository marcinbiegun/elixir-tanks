defmodule ECS.Registry.Component do
  @initial_state %{}

  def start(game_id) do
    Agent.start_link(fn -> @initial_state end, name: name(game_id))
  end

  def clear(game_id) do
    Agent.update(name(game_id), fn _state -> @initial_state end)
  end

  def put(game_id, component_type, component_pid) do
    Agent.update(name(game_id), fn state ->
      new_components = Map.get(state, component_type, []) ++ [component_pid]
      Map.put(state, component_type, new_components)
    end)
  end

  def remove(game_id, component_type, component_pid) do
    Agent.update(name(game_id), fn state ->
      new_components = Map.get(state, component_type, []) |> Enum.filter(&(&1 != component_pid))
      Map.put(state, component_type, new_components)
    end)
  end

  def get(game_id, component_type) do
    Agent.get(name(game_id), fn state ->
      Map.get(state, component_type, [])
    end)
  end

  defp name(game_id), do: {:via, Registry, {Registry.ECS.Registry.Component, game_id}}
end
