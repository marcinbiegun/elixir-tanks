defmodule TanksGame.IntegrationTest do
  use ExUnit.Case

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
    end
  end

  describe "registering entities" do
  end

  describe "velocity system" do
    test "projectile movement" do
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
end
