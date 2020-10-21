defmodule ECS.Cache do
  @initial_state %{}

  # TODO: move out of ECS module

  def start(game_id) do
    Agent.start_link(fn -> @initial_state end, name: name(game_id))
  end

  def clear(game_id) do
    Agent.update(name(game_id), fn _state -> @initial_state end)
  end

  def register(game_id, type) do
    Agent.update(name(game_id), fn state ->
      new_type_state = Map.get(state, type, type.initial_state())
      Map.put(state, type, new_type_state)
    end)
  end

  def update(game_id, type, update_fn) do
    Agent.update(name(game_id), fn state ->
      new_type_state = update_fn.(Map.get(state, type))
      Map.put(state, type, new_type_state)
    end)
  end

  def clear(game_id, type) do
    Agent.update(name(game_id), fn state ->
      Map.put(state, type, type.initial_state())
    end)
  end

  def get(game_id, type) do
    Agent.get(name(game_id), fn state ->
      Map.get(state, type)
    end)
  end

  defp name(game_id), do: {:via, Registry, {Registry.ECS.Cache, game_id}}
end
