defmodule Tanks.Game.Components.Health do
  @type t :: %__MODULE__{
          pid: pid(),
          state: %{
            current: Integer.t(),
            max: Integer.t()
          }
        }

  use ECS.Component

  defstruct [:pid, :state]

  def new(hp) do
    state = %{current: hp, max: hp}
    ECS.Component.new(__MODULE__, state)
  end
end
