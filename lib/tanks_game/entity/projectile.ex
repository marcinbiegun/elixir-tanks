defmodule TanksGame.Entity.Projectile do
  alias TanksGame.Components.{
    Position,
    Size,
    Velocity
  }

  @type t :: %__MODULE__{
          id: Integer.t(),
          components: %{
            position: Position.t(),
            size: Size.t(),
            velocity: Velocity.t()
          }
        }

  defstruct [:id, :components]

  @size 0.5

  def new(x, y, vel_x, vel_y) do
    position = TanksGame.Components.Position.new(%{x: x, y: y})
    size = TanksGame.Components.Size.new(%{size: @size})
    velocity = TanksGame.Components.Velocity.new(%{x: vel_x, y: vel_y})

    components = %{
      position: position,
      size: size,
      velocity: velocity
    }

    ECS.Entity.new(__MODULE__, components)
  end
end
