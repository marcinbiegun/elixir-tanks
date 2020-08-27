defmodule ECS.Registry.Entity do
  def start do
    initial_state = %{}
    Agent.start_link(fn -> initial_state end, name: __MODULE__)
  end

  def put(%type{id: id} = entity) do
    Agent.update(__MODULE__, fn state ->
      type_map =
        Map.get(state, type, %{})
        |> Map.put(id, pack(entity))

      Map.put(state, type, type_map)
    end)
  end

  def get(type) do
    Agent.get(__MODULE__, fn state ->
      Map.get(state, type, %{})
    end)
  end

  def state() do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def get(type, id) do
    Agent.get(__MODULE__, fn state ->
      Map.get(state, type, %{})
      |> Map.get(id)
      |> unpack(type, id)
    end)
  end

  def pack(%{components: components} = _entity) do
    components
    |> Enum.map(fn {key, %type{pid: pid}} ->
      {key, {type, pid}}
    end)
    |> Map.new()
  end

  def unpack(nil, _type, _id), do: nil

  def unpack(packed, type, id) do
    components =
      packed
      |> Enum.map(fn {key, {component_type, pid}} ->
        component_state = ECS.Component.get_state(pid)
        component = %{__struct__: component_type, pid: pid, state: component_state}
        {key, component}
      end)
      |> Map.new()

    struct(type, %{id: id, components: components})
  end
end
