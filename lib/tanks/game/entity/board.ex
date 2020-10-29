defmodule Tanks.Game.Entity.Board do
  alias Tanks.Game.Components.{
    Tiles
  }

  @type t :: %__MODULE__{
          id: Integer.t(),
          components: %{
            tiles: Tiles.t()
          }
        }

  defstruct [:id, :components]

  def new(tiles) do
    components = %{
      tiles: Tanks.Game.Components.Tiles.new(%{tiles: tiles})
    }

    ECS.Entity.new(__MODULE__, components)
  end
end
