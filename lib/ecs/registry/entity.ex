defmodule ECS.Registry.Entity do
  def start do
    initial_state = %{}
    Agent.start_link(fn -> initial_state end, name: __MODULE__)
  end

  def put(entity_type, entity_id) do
    Agent.update(__MODULE__, fn state ->
      new_components = Map.get(state, entity_type, []) ++ [entity_id]
      Map.put(state, entity_type, new_components)
    end)
  end

  def get(entity_type) do
    Agent.get(__MODULE__, fn state ->
      Map.get(state, entity_type, [])
    end)
  end
end
