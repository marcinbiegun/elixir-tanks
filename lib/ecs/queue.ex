defmodule ECS.Queue do
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
      new_list = Map.get(state, type, [])
      Map.put(state, type, new_list)
    end)
  end

  def put(game_id, type, el) do
    Agent.update(name(game_id), fn state ->
      updated_list = [el | Map.get(state, type)]
      Map.put(state, type, updated_list)
    end)
  end

  def pop(game_id, type) do
    Agent.get_and_update(name(game_id), fn state ->
      list = Map.get(state, type)

      if Enum.empty?(list) do
        {nil, state}
      else
        [el | rest] = list
        updated_state = Map.put(state, type, rest)
        {el, updated_state}
      end
    end)
  end

  def pop_all(game_id, type) do
    Agent.get_and_update(name(game_id), fn state ->
      {Map.get(state, type, []), Map.put(state, type, [])}
    end)
  end

  def get(game_id, type) do
    Agent.get(name(game_id), fn state ->
      Map.get(state, type, [])
    end)
  end

  defp name(game_id), do: {:via, Registry, {Registry.ECS.Queue, game_id}}
end
