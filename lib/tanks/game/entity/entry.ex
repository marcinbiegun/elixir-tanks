defmodule Tanks.Game.Entity.Entry do
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

  @shape :rectangle
  @blocking false

  def new(x, y) do
    position = Position.new(%{x: x, y: y})

    size =
      Size.new(%{shape: {@shape, Tanks.Game.Content.Config.tile_size()}, blocking: @blocking})

    components = %{
      position: position,
      size: size
    }

    ECS.Entity.new(__MODULE__, components)
  end
end
