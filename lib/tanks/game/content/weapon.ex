defmodule Tanks.Game.Content.Weapon do
  @projectile_speed 10.0
  @projectile_lifetime 2000

  def fire_projectile(player_x, player_y, velocity_x, velocity_y) do
    # Ensure normalized values
    velocity_x = max(-1, velocity_x) |> min(1)
    velocity_y = max(-1, velocity_y) |> min(1)

    Tanks.Game.Entity.Projectile.new(
      player_x,
      player_y,
      velocity_x * @projectile_speed,
      velocity_y * @projectile_speed,
      @projectile_lifetime
    )
  end
end
