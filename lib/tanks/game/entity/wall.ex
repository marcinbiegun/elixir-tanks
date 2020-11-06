defmodule Tanks.Game.Entity.Wall do
  alias Tanks.Game.Components.{
    Health,
    Position,
    Size
  }

  @type t :: %__MODULE__{
          id: Integer.t(),
          components: %{
            health: Health.t(),
            position: Position.t(),
            size: Size.t()
          }
        }

  defstruct [:id, :components]

  @size 30
  @hp 5

  def new(x, y) do
    position = Position.new(%{x: x, y: y})
    size = Size.new(%{size: @size})
    health = Health.new(@hp)

    components = %{
      health: health,
      position: position,
      size: size
    }

    ECS.Entity.new(__MODULE__, components)
  end
end
