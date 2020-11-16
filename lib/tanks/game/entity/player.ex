defmodule Tanks.Game.Entity.Player do
  alias Tanks.Game.Components.{
    Control,
    Health,
    Position,
    Size
  }

  @type t :: %__MODULE__{
          id: Integer.t(),
          components: %{
            control: Control.t(),
            health: Health.t(),
            position: Position.t(),
            size: Size.t()
          }
        }

  defstruct [:id, :components]

  @speed 5.0
  @shape :rectangle
  @size 20.0
  @hp 10

  def new(), do: new(0, 0)

  def new(x, y) do
    control =
      Control.new(%{
        down: false,
        left: false,
        right: false,
        up: false,
        speed: @speed
      })

    size = Size.new(%{shape: {@shape, @size}})
    position = Position.new(%{x: x, y: y})
    health = Health.new(@hp)

    components = %{
      control: control,
      health: health,
      position: position,
      size: size
    }

    ECS.Entity.new(__MODULE__, components)
  end
end
