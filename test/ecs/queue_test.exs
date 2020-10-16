defmodule Tanks.Game.ECS.QueueTest do
  use ExUnit.Case

  describe "queue" do
    test "works as FIFO queue" do
      ECS.Queue.register(:test)

      ECS.Queue.put(:test, "first")
      ECS.Queue.put(:test, "second")

      assert ECS.Queue.get(:test) == ["second", "first"]
      assert ECS.Queue.pop(:test) == "second"
      assert ECS.Queue.get(:test) == ["first"]
      assert ECS.Queue.pop(:test) == "first"
      assert ECS.Queue.get(:test) == []
      assert ECS.Queue.pop(:test) == nil
      assert ECS.Queue.get(:test) == []

      ECS.Queue.put(:test, "A")
      ECS.Queue.put(:test, "B")
      ECS.Queue.put(:test, "C")

      assert ECS.Queue.pop_all(:test) == ["C", "B", "A"]
      assert ECS.Queue.pop_all(:test) == []

      Tanks.Game.reset()
    end
  end
end
