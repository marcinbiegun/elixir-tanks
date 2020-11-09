defmodule Tanks.Game.Entity.Zombie do
  alias Tanks.Game.Components.{
    Brain,
    Control,
    Size,
    Position
  }

  @type t :: %__MODULE__{
          id: Integer.t(),
          components: %{
            brain: Brain.t(),
            control: Control.t(),
            size: Size.t(),
            position: Position.t()
          }
        }

  defstruct [:id, :components]

  @speed 1
  @size 20.0

  def new(x, y) do
    brain = Tanks.Game.Components.Brain.new()

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
    position = Tanks.Game.Components.Position.new(%{x: x, y: y})

    components = %{
      brain: brain,
      control: control,
      size: size,
      position: position
    }

    ECS.Entity.new(__MODULE__, components)
  end
end
