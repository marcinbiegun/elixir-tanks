defmodule Tanks.Game.Components.Size do
  @type t :: %__MODULE__{
          pid: pid(),
          state: %{
            size: float()
          }
        }

  use ECS.Component

  defstruct [:pid, :state]

  def new(%{size: _size} = state) do
    ECS.Component.new(__MODULE__, state)
  end
end
