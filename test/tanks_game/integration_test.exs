defmodule TanksGame.IntegrationTest do
  use ExUnit.Case

  describe "entity registry" do
    test "getting entity by ID" do
      player = TanksGame.Entity.Player.new()
      fetched_player = ECS.Registry.Entity.get(TanksGame.Entity.Player, player.id)

      assert fetched_player.id == player.id
      assert fetched_player.components == player.components

      TanksGame.reset()
    end
  end

  describe "entities" do
    test "creating and reloading entities" do
      player = TanksGame.Entity.Player.new()

      assert player.__struct__ == TanksGame.Entity.Player
      assert player.components.position.__struct__ == TanksGame.Components.Position

      player = ECS.Entity.reload(player)

      assert player.__struct__ == TanksGame.Entity.Player
      assert player.components.position.__struct__ == TanksGame.Components.Position

      TanksGame.reset()
    end

    test "getting list of all entites of a given type" do
      projectile1 = TanksGame.Entity.Projectile.new(0, 0, 1, 0)
      projectile2 = TanksGame.Entity.Projectile.new(10, 10, 0, 1)

      [fetched_projectile1, fetched_projectile2] =
        ECS.Registry.Entity.get(TanksGame.Entity.Projectile)
        |> Enum.sort_by(& &1.id)

      assert projectile1 == fetched_projectile1
      assert projectile2 == fetched_projectile2

      TanksGame.reset()
    end
  end

  describe "velocity system" do
    test "projectile movement" do
      projectile = TanksGame.Entity.Projectile.new(0, 0, 1, 2)
      assert projectile.components.position.state.x == 0
      assert projectile.components.position.state.y == 0

      TanksGame.System.Velocity.process()

      projectile = ECS.Entity.reload(projectile)
      assert projectile.components.position.state.x == 1
      assert projectile.components.position.state.y == 2

      TanksGame.System.Velocity.process()

      projectile = ECS.Entity.reload(projectile)
      assert projectile.components.position.state.x == 2
      assert projectile.components.position.state.y == 4

      TanksGame.reset()
    end
  end

  describe "control system" do
    test "player control" do
      player = TanksGame.Entity.Player.new()
      assert player.components.control.state.right == false

      control = player.components.control

      control.pid
      |> ECS.Component.update(Map.put(control.state, :right, true))

      player = ECS.Entity.reload(player)
      assert player.components.control.state.right == true
      assert player.components.position.state.x == 0

      TanksGame.System.Movement.process()

      player = ECS.Entity.reload(player)
      assert player.components.position.state.x == 5

      TanksGame.reset()
    end
  end
end
