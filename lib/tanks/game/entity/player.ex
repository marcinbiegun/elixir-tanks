defmodule Tanks.Game.Entity.Player do
  alias Tanks.Game.Components.{
    Control,
    Size,
    Position
  }

  @type t :: %__MODULE__{
          id: Integer.t(),
          components: %{
            control: Control.t(),
            size: Size.t(),
            position: Position.t()
          }
        }

  defstruct [:id, :components]

  @speed 5.0
  @size 20.0

  def new() do
    control =
      Tanks.Game.Components.Control.new(%{
        down: false,
        left: false,
        right: false,
        up: false,
        speed: @speed
      })

    shape = {:rectangle, @size}
    size = Tanks.Game.Components.Size.new(%{shape: shape})
    position = Tanks.Game.Components.Position.new(%{x: 0, y: 0})

    components = %{
      control: control,
      size: size,
      position: position
    }

    ECS.Entity.new(__MODULE__, components)
  end
end
