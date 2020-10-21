defmodule Tanks.Game.ECS.QueueTest do
  use ExUnit.Case

  @game_id 123

  describe "queue" do
    test "works as FIFO queue" do
      ECS.Queue.register(@game_id, :test)

      ECS.Queue.put(@game_id, :test, "first")
      ECS.Queue.put(@game_id, :test, "second")

      assert ECS.Queue.get(@game_id, :test) == ["second", "first"]
      assert ECS.Queue.pop(@game_id, :test) == "second"
      assert ECS.Queue.get(@game_id, :test) == ["first"]
      assert ECS.Queue.pop(@game_id, :test) == "first"
      assert ECS.Queue.get(@game_id, :test) == []
      assert ECS.Queue.pop(@game_id, :test) == nil
      assert ECS.Queue.get(@game_id, :test) == []

      ECS.Queue.put(@game_id, :test, "A")
      ECS.Queue.put(@game_id, :test, "B")
      ECS.Queue.put(@game_id, :test, "C")

      assert ECS.Queue.pop_all(@game_id, :test) == ["C", "B", "A"]
      assert ECS.Queue.pop_all(@game_id, :test) == []
    end
  end
end
