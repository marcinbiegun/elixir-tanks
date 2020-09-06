defmodule TanksGame.Entity.Zombie do
  alias TanksGame.Components.{
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
  @size 20

  def new(x, y) do
    brain = TanksGame.Components.Brain.new()

    control =
      TanksGame.Components.Control.new(%{
        down: false,
        left: false,
        right: false,
        up: false,
        speed: @speed
      })

    size = TanksGame.Components.Size.new(%{size: @size})
    position = TanksGame.Components.Position.new(%{x: x, y: y})

    components = %{
      brain: brain,
      control: control,
      size: size,
      position: position
    }

    ECS.Entity.new(__MODULE__, components)
  end
end
