defmodule Tanks.Game.Components.Velocity do
  @type t :: %__MODULE__{
          pid: pid(),
          state: %{
            x: Integer.t(),
            y: Integer.t()
          }
        }

  use ECS.Component

  # defstruct [:x, :y]
  defstruct [:pid, :state]

  def new(%{x: _x, y: _y} = state) do
    ECS.Component.new(__MODULE__, state)
  end
end
