defmodule TanksGame.Entity.Zombie do
  alias TanksGame.Components.{
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

  @speed 5
  @size 1

  def new(x, y) do
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
      control: control,
      size: size,
      position: position
    }

    ECS.Entity.new(__MODULE__, components)
  end
end
