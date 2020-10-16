defmodule Tanks.Game.Entity.Wall do
  alias Tanks.Game.Components.{
    Position,
    Size
  }

  @type t :: %__MODULE__{
          id: Integer.t(),
          components: %{
            position: Position.t(),
            size: Size.t()
          }
        }

  defstruct [:id, :components]

  @size 30

  def new(x, y) do
    position = Tanks.Game.Components.Position.new(%{x: x, y: y})
    size = Tanks.Game.Components.Size.new(%{size: @size})

    components = %{
      position: position,
      size: size
    }

    ECS.Entity.new(__MODULE__, components)
  end
end
