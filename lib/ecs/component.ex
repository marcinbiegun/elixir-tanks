defmodule ECS.Component do
  @moduledoc """
  A behaviour for compoments.
  """
  defstruct [:pid, :state]

  @type t :: %__MODULE__{
          pid: pid(),
          state: map()
        }

  # Required functions by component implementations
  @callback new(map()) :: map()

  defmacro __using__(_options) do
    quote do
      @behaviour ECS.Component
    end
  end

  def new(component_type, initial_state) do
    {:ok, pid} = ECS.Component.Agent.start_link(initial_state)
    struct(component_type, %{pid: pid, state: initial_state})
  end

  def get(pid) do
    state = ECS.Component.Agent.get(pid)
    %{pid: pid, state: state}
  end

  def get_state(pid) do
    ECS.Component.Agent.get(pid)
  end

  def update(pid, new_state) do
    ECS.Component.Agent.set(pid, new_state)
    %{pid: pid, state: new_state}
  end
end
