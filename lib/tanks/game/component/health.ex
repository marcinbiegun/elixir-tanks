defmodule Tanks.Game.Components.Health do
  @type t :: %__MODULE__{
          pid: pid(),
          state: %{
            hp: Integer.t()
          }
        }

  use ECS.Component

  defstruct [:pid, :state]

  def new(hp) do
    state = %{hp: hp}
    ECS.Component.new(__MODULE__, state)
  end
end
