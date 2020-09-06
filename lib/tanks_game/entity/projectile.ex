defmodule TanksGame.Entity.Projectile do
  alias TanksGame.Components.{
    Lifetime,
    Position,
    Size,
    Velocity
  }

  @type t :: %__MODULE__{
          id: Integer.t(),
          components: %{
            lifetime: Lifetime.t(),
            position: Position.t(),
            size: Size.t(),
            velocity: Velocity.t()
          }
        }

  defstruct [:id, :components]

  @size 10

  def new(x, y, vel_x, vel_y, lifetime \\ 10_000) do
    lifetime = TanksGame.Components.Lifetime.new(lifetime)
    position = TanksGame.Components.Position.new(%{x: x, y: y})
    size = TanksGame.Components.Size.new(%{size: @size})
    velocity = TanksGame.Components.Velocity.new(%{x: vel_x, y: vel_y})

    components = %{
      lifetime: lifetime,
      position: position,
      size: size,
      velocity: velocity
    }

    ECS.Entity.new(__MODULE__, components)
  end
end
