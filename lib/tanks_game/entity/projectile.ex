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

  def new() do
    position = TanksGame.Components.Position.new(%{x: 0, y: 0})
    size = TanksGame.Components.Size.new(%{size: @size})
    velocity = TanksGame.Components.Velocity.new(%{x: 0, y: 0})

    components = %{
      position: position,
      size: size,
      velocity: velocity
    }

    ECS.Entity.new(__MODULE__, components)
  end
end
