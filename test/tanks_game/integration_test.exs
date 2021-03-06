defmodule Tanks.Game.IntegrationTest do
  use ExUnit.Case

  @game_id 123
  @level nil

  setup do
    on_exit(fn ->
      Tanks.GameServer.delete(@game_id)
    end)

    Tanks.GameServer.create(@game_id, @level, no_tick: true)

    %{game_id: @game_id}
  end

  describe "entity registry" do
    test "getting entity by ID" do
      player =
        Tanks.Game.Entity.Player.new()
        |> Tanks.GameECS.add_entity(@game_id)

      fetched_player = ECS.Registry.Entity.get(@game_id, Tanks.Game.Entity.Player, player.id)

      assert fetched_player.id == player.id
      assert fetched_player.components == player.components
    end
  end

  describe "entities" do
    test "creating and reloading entities" do
      player =
        Tanks.Game.Entity.Player.new()
        |> Tanks.GameECS.add_entity(@game_id)

      assert player.__struct__ == Tanks.Game.Entity.Player
      assert player.components.position.__struct__ == Tanks.Game.Components.Position

      player = ECS.Entity.reload(player)

      assert player.__struct__ == Tanks.Game.Entity.Player
      assert player.components.position.__struct__ == Tanks.Game.Components.Position
    end

    test "getting list of all entites of a given type" do
      projectile1 =
        Tanks.Game.Entity.Projectile.new(0, 0, 1, 0)
        |> Tanks.GameECS.add_entity(@game_id)

      projectile2 =
        Tanks.Game.Entity.Projectile.new(10, 10, 0, 1)
        |> Tanks.GameECS.add_entity(@game_id)

      [fetched_projectile1, fetched_projectile2] =
        ECS.Registry.Entity.all(@game_id, Tanks.Game.Entity.Projectile)
        |> Enum.sort_by(& &1.id)

      assert projectile1 == fetched_projectile1
      assert projectile2 == fetched_projectile2
    end
  end

  describe "velocity system" do
    test "projectile movement" do
      projectile =
        Tanks.Game.Entity.Projectile.new(0, 0, 1, 2)
        |> Tanks.GameECS.add_entity(@game_id)

      assert projectile.components.position.state.x == 0
      assert projectile.components.position.state.y == 0

      Tanks.Game.System.Velocity.process(@game_id)

      projectile = ECS.Entity.reload(projectile)
      assert projectile.components.position.state.x == 1
      assert projectile.components.position.state.y == 2

      Tanks.Game.System.Velocity.process(@game_id)

      projectile = ECS.Entity.reload(projectile)
      assert projectile.components.position.state.x == 2
      assert projectile.components.position.state.y == 4
    end
  end

  describe "control system" do
    test "player control" do
      player =
        Tanks.Game.Entity.Player.new()
        |> Tanks.GameECS.add_entity(@game_id)

      assert player.components.control.state.right == false

      control = player.components.control

      control.pid
      |> ECS.Component.update(Map.put(control.state, :right, true))

      player = ECS.Entity.reload(player)
      assert player.components.control.state.right == true
      assert player.components.position.state.x == 0

      Tanks.Game.System.Movement.process(@game_id)

      player = ECS.Entity.reload(player)
      assert player.components.position.state.x == 5
    end
  end

  describe "lifetime system" do
    test "test dying" do
      lifetime = 50

      projectile =
        Tanks.Game.Entity.Projectile.new(0, 0, 0, 0, lifetime)
        |> Tanks.GameECS.add_entity(@game_id)

      projectile_id = projectile.id

      Tanks.Game.System.LifetimeDying.process(@game_id)

      Tanks.Game.Server.Impl.build_client_state(@game_id)

      assert [] = ECS.Queue.get(@game_id, :internal)

      Process.sleep(lifetime + 1)

      Tanks.Game.System.LifetimeDying.process(@game_id)

      assert [
               %Tanks.Game.Event.Destroy{
                 entity_id: ^projectile_id,
                 entity_module: Tanks.Game.Entity.Projectile
               }
             ] = ECS.Queue.get(@game_id, :internal)
    end
  end

  describe "collision system" do
    test "projectile vs wall collision" do
      projectile =
        Tanks.Game.Entity.Projectile.new(0, 0, 0, 0)
        |> Tanks.GameECS.add_entity(@game_id)

      projectile_id = projectile.id

      _wall =
        Tanks.Game.Entity.Wall.new(0, 0)
        |> Tanks.GameECS.add_entity(@game_id)

      Tanks.Game.System.Collision.process(@game_id)

      assert [
               %Tanks.Game.Event.Destroy{
                 entity_id: ^projectile_id,
                 entity_module: Tanks.Game.Entity.Projectile
               },
               _
             ] = ECS.Queue.get(@game_id, :internal)
    end

    test "projectile vs zombie projectile collision" do
      projectile =
        Tanks.Game.Entity.Projectile.new(0, 0, 0, 0)
        |> Tanks.GameECS.add_entity(@game_id)

      projectile_id = projectile.id

      zombie =
        Tanks.Game.Entity.Zombie.new(0, 0)
        |> Tanks.GameECS.add_entity(@game_id)

      zombie_id = zombie.id

      Tanks.Game.System.Collision.process(@game_id)

      assert [
               %Tanks.Game.Event.Destroy{
                 entity_id: ^projectile_id,
                 entity_module: Tanks.Game.Entity.Projectile
               },
               %Tanks.Game.Event.Destroy{
                 entity_id: ^zombie_id,
                 entity_module: Tanks.Game.Entity.Zombie
               }
             ] = ECS.Queue.get(@game_id, :internal) |> Enum.sort_by(& &1.entity_module)
    end

    test "projectile vs board tile collision" do
      projectile =
        Tanks.Game.Entity.Projectile.new(0, 0, 0, 0)
        |> Tanks.GameECS.add_entity(@game_id)

      projectile_id = projectile.id

      tile_size = 32

      tiles = [
        [:empty, :empty, :empty],
        [:empty, :wall, :empty],
        [:empty, :empty, :empty]
      ]

      _board =
        Tanks.Game.Entity.Board.new(tiles)
        |> Tanks.GameECS.add_entity(@game_id)

      Tanks.Game.System.Collision.process(@game_id)

      assert [] == ECS.Queue.get(@game_id, :internal)

      new_position = %{x: tile_size, y: tile_size}
      ECS.Component.update(projectile.components.position.pid, new_position)

      Tanks.Game.System.Collision.process(@game_id)

      assert [
               %Tanks.Game.Event.Destroy{
                 entity_id: ^projectile_id,
                 entity_module: Tanks.Game.Entity.Projectile
               }
             ] = ECS.Queue.get(@game_id, :internal)
    end
  end

  describe "health points" do
    test "losing hp and dying" do
      # Spawn wall
      wall =
        Tanks.Game.Entity.Wall.new(10, 10)
        |> Tanks.GameECS.add_entity(@game_id)

      assert wall.components.health.state.current == 5

      # Projectile hits wall
      projectile =
        Tanks.Game.Entity.Projectile.new(10, 10, 0, 0)
        |> Tanks.GameECS.add_entity(@game_id)

      Tanks.Game.Server.Impl.tick(@game_id, 1)

      refute ECS.Registry.Entity.get(@game_id, projectile.__struct__, projectile.id)

      wall = ECS.Entity.reload(wall)
      assert wall.components.health.state.current == 4

      # Projectile hits wall
      Tanks.Game.Entity.Projectile.new(10, 10, 0, 0)
      |> Tanks.GameECS.add_entity(@game_id)

      Tanks.Game.Server.Impl.tick(@game_id, 2)

      wall = ECS.Entity.reload(wall)
      assert wall.components.health.state.current == 3

      # Projectile hits wall
      Tanks.Game.Entity.Projectile.new(10, 10, 0, 0)
      |> Tanks.GameECS.add_entity(@game_id)

      Tanks.Game.Server.Impl.tick(@game_id, 4)

      wall = ECS.Entity.reload(wall)
      assert wall.components.health.state.current == 2

      # Projectile hits wall
      Tanks.Game.Entity.Projectile.new(10, 10, 0, 0)
      |> Tanks.GameECS.add_entity(@game_id)

      Tanks.Game.Server.Impl.tick(@game_id, 5)

      wall = ECS.Entity.reload(wall)
      assert wall.components.health.state.current == 1

      # Projectile hits wall
      Tanks.Game.Entity.Projectile.new(10, 10, 0, 0)
      |> Tanks.GameECS.add_entity(@game_id)

      Tanks.Game.Server.Impl.tick(@game_id, 6)

      # Wall destroyed
      refute ECS.Registry.Entity.get(@game_id, wall.__struct__, wall.id)
    end
  end

  describe "position cache" do
    test "detecting collisions" do
      assert [] == Tanks.Game.Cache.Position.colliding_entities(@game_id, 0, 0, {:circle, 10})

      projectile =
        Tanks.Game.Entity.Projectile.new(0, 0, 0, 0)
        |> Tanks.GameECS.add_entity(@game_id)

      projectile_shape = projectile.components.size.state.shape
      {:circle, projectile_diameter} = projectile_shape
      assert [] == Tanks.Game.Cache.Position.colliding_entities(@game_id, 0, 0, {:circle, 10})

      ECS.Registry.Entity.all(@game_id)

      Tanks.Game.Cache.Position.update(@game_id)

      assert [{Tanks.Game.Entity.Projectile, projectile.id}] ==
               Tanks.Game.Cache.Position.colliding_entities(@game_id, 0, 0, {:circle, 1})

      assert [] ==
               Tanks.Game.Cache.Position.colliding_entities(
                 @game_id,
                 projectile_diameter / 2 + 2,
                 projectile_diameter / 2 + 2,
                 {:circle, 1}
               )

      assert [{Tanks.Game.Entity.Projectile, projectile.id}] ==
               Tanks.Game.Cache.Position.colliding_entities(
                 @game_id,
                 projectile_diameter / 2 + 2,
                 projectile_diameter / 2 + 2,
                 {:circle, 10}
               )
    end
  end
end
