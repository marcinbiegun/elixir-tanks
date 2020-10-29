defmodule Tanks.Game.Components.Tiles do
  @type t :: %__MODULE__{
          pid: pid(),
          state: %{
            tiles: [atom()]
          }
        }

  use ECS.Component

  defstruct [:pid, :state]

  def new(%{tiles: _tiles} = state) do
    ECS.Component.new(__MODULE__, state)
  end
end
