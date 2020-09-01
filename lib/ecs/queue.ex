defmodule ECS.Queue do
  @initial_state %{}

  def start do
    Agent.start_link(fn -> @initial_state end, name: __MODULE__)
  end

  def clear do
    Agent.update(__MODULE__, fn _state -> @initial_state end)
  end

  def register(type) do
    Agent.update(__MODULE__, fn state ->
      new_list = Map.get(state, type, [])
      Map.put(state, type, new_list)
    end)
  end

  def put(type, el) do
    Agent.update(__MODULE__, fn state ->
      updated_list = [el | Map.get(state, type)]
      Map.put(state, type, updated_list)
    end)
  end

  def pop(type) do
    Agent.get_and_update(__MODULE__, fn state ->
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

  def pop_all(type) do
    Agent.get_and_update(__MODULE__, fn state ->
      {Map.get(state, type, []), Map.put(state, type, [])}
    end)
  end

  def get(type) do
    Agent.get(__MODULE__, fn state ->
      Map.get(state, type, [])
    end)
  end
end
