defmodule ECS.Cache do
  @initial_state %{}

  def start do
    Agent.start_link(fn -> @initial_state end, name: __MODULE__)
  end

  def clear do
    Agent.update(__MODULE__, fn _state -> @initial_state end)
  end

  def register(type) do
    Agent.update(__MODULE__, fn state ->
      new_type_state = Map.get(state, type, type.initial_state())
      Map.put(state, type, new_type_state)
    end)
  end

  def update(type, update_fn) do
    Agent.update(__MODULE__, fn state ->
      new_type_state = update_fn.(Map.get(state, type))
      Map.put(state, type, new_type_state)
    end)
  end

  def clear(type) do
    Agent.update(__MODULE__, fn state ->
      Map.put(state, type, type.initial_state())
    end)
  end

  def get(type) do
    Agent.get(__MODULE__, fn state ->
      Map.get(state, type)
    end)
  end
end
