defmodule Tanks.Game.Components.Size do
  @type shape :: {:rectangle, float()} | {:circle, float()}

  @type t :: %__MODULE__{
          pid: pid(),
          state: %{
            shape: shape(),
            blocking: boolean()
          }
        }

  use ECS.Component

  defstruct [:pid, :state]

  def new(%{shape: _shape, blocking: _blocking} = state) do
    ECS.Component.new(__MODULE__, state)
  end
end
