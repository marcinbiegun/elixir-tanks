defmodule ECS.Component.Agent do
  def start_link(initial_state \\ %{}, opts \\ []) do
    Agent.start_link(fn -> initial_state end, opts)
  end

  def get(pid) do
    Agent.get(pid, & &1)
  end

  def get(pid, key) do
    Agent.get(pid, &Map.get(&1, key))
  end

  def set(pid, new_state) do
    Agent.update(pid, &Map.merge(&1, new_state))
  end

  def set(pid, key, value) do
    Agent.update(pid, &Map.put(&1, key, value))
  end

  def stop(pid) do
    Agent.stop(pid)
  end
end
