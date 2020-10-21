defmodule ECS.Registry.Id do
  @initial_state 0

  def start() do
    Agent.start_link(fn -> @initial_state end, name: __MODULE__)
  end

  def clear() do
    Agent.update(__MODULE__, fn _state -> @initial_state end)
  end

  def generate_id() do
    Agent.update(__MODULE__, fn last_id -> last_id + 1 end)
    Agent.get(__MODULE__, fn last_id -> last_id end)
  end
end
