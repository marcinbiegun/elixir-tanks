defmodule TanksGame.Components.Control do
  @type t :: %__MODULE__{
          pid: pid(),
          state: %{
            down: boolean(),
            left: boolean(),
            right: boolean(),
            up: boolean(),
            speed: Integer.t()
          }
        }

  use ECS.Component

  # defstruct [:down, :left, :right, :up, :speed]
  defstruct [:pid, :state]

  def new(%{down: _down, left: _left, right: _right, up: _up, speed: _speed} = state) do
    ECS.Component.new(__MODULE__, state)
  end
end
