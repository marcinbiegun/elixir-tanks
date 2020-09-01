defmodule ECS.Registry.Component do
  @initial_state %{}

  def start do
    Agent.start_link(fn -> @initial_state end, name: __MODULE__)
  end

  def clear do
    Agent.update(__MODULE__, fn _state -> @initial_state end)
  end

  def put(component_type, component_pid) do
    Agent.update(__MODULE__, fn state ->
      new_components = Map.get(state, component_type, []) ++ [component_pid]
      Map.put(state, component_type, new_components)
    end)
  end

  def remove(component_type, component_pid) do
    Agent.update(__MODULE__, fn state ->
      new_components = Map.get(state, component_type, []) |> Enum.filter(&(&1 != component_pid))
      Map.put(state, component_type, new_components)
    end)
  end

  def get(component_type) do
    Agent.get(__MODULE__, fn state ->
      Map.get(state, component_type, [])
    end)
  end
end
