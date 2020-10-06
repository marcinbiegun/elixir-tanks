defmodule TanksGame.IntegrationTest do
  use ExUnit.Case

  setup do
    on_exit(fn ->
      TanksGame.reset()
    end)
  end

  describe "entity registry" do
    test "getting entity by ID" do
      player = TanksGame.Entity.Player.new()
      fetched_player = ECS.Registry.Entity.get(TanksGame.Entity.Player, player.id)

      assert fetched_player.id == player.id
      assert fetched_player.components == player.components
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
        ECS.Registry.Entity.all(TanksGame.Entity.Projectile)
        |> Enum.sort_by(& &1.id)

      assert projectile1 == fetched_projectile1
      assert projectile2 == fetched_projectile2
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
    end
  end

  describe "lifetime system" do
    test "test dying" do
      lifetime = 50
      projectile = TanksGame.Entity.Projectile.new(0, 0, 0, 0, lifetime)
      projectile_id = projectile.id

      TanksGame.System.LifetimeDying.process()

      assert [] = ECS.Queue.get(:internal)

      Process.sleep(lifetime)

      TanksGame.System.LifetimeDying.process()

      assert [
               %TanksGame.Event.Destroy{
                 entity_id: ^projectile_id,
                 entity_module: TanksGame.Entity.Projectile
               }
             ] = ECS.Queue.get(:internal)
    end
  end

  describe "collision system" do
    test "projectile vs wall collision" do
      projectile = TanksGame.Entity.Projectile.new(0, 0, 0, 0)
      projectile_id = projectile.id
      _wall = TanksGame.Entity.Wall.new(0, 0)

      TanksGame.System.Collision.process()

      assert [
               %TanksGame.Event.Destroy{
                 entity_id: ^projectile_id,
                 entity_module: TanksGame.Entity.Projectile
               }
             ] = ECS.Queue.get(:internal)
    end

    test "projectile vs zombie projectile collision" do
      projectile = TanksGame.Entity.Projectile.new(0, 0, 0, 0)
      projectile_id = projectile.id
      zombie = TanksGame.Entity.Zombie.new(0, 0)
      zombie_id = zombie.id

      TanksGame.System.Collision.process()

      assert [
               %TanksGame.Event.Destroy{
                 entity_id: ^projectile_id,
                 entity_module: TanksGame.Entity.Projectile
               },
               %TanksGame.Event.Destroy{
                 entity_id: ^zombie_id,
                 entity_module: TanksGame.Entity.Zombie
               }
             ] = ECS.Queue.get(:internal) |> Enum.sort_by(& &1.entity_module)
    end
  end

  describe "position cache" do
    test "detecting collisions" do
      assert [] == TanksGame.Cache.Position.colliding_entities(0, 0, 10)

      projectile = TanksGame.Entity.Projectile.new(0, 0, 0, 0)
      projectile_size = projectile.components.size.state.size
      assert [] == TanksGame.Cache.Position.colliding_entities(0, 0, 10)

      TanksGame.Cache.Position.update()

      assert [{TanksGame.Entity.Projectile, 1}] ==
               TanksGame.Cache.Position.colliding_entities(0, 0, 1)

      assert [] ==
               TanksGame.Cache.Position.colliding_entities(
                 projectile_size / 2 + 2,
                 projectile_size / 2 + 2,
                 1
               )

      assert [{TanksGame.Entity.Projectile, 1}] ==
               TanksGame.Cache.Position.colliding_entities(
                 projectile_size / 2 + 2,
                 projectile_size / 2 + 2,
                 10
               )
    end
  end
end
