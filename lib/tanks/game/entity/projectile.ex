defmodule Tanks.Game.Entity.Projectile do
  alias Tanks.Game.Components.{
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

  @size 10.0

  def new(x, y, vel_x, vel_y, lifetime \\ 10_000) do
    lifetime = Tanks.Game.Components.Lifetime.new(lifetime)
    position = Tanks.Game.Components.Position.new(%{x: x, y: y})
    shape = {:circle, @size}
    size = Tanks.Game.Components.Size.new(%{shape: shape})
    velocity = Tanks.Game.Components.Velocity.new(%{x: vel_x, y: vel_y})

    components = %{
      lifetime: lifetime,
      position: position,
      size: size,
      velocity: velocity
    }

    ECS.Entity.new(__MODULE__, components)
  end
end
