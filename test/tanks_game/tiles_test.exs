defmodule Tanks.Game.TilesTest do
  use ExUnit.Case

  alias Utils.Tiles

  describe "tiles" do
    test "new" do
      assert Tiles.new(2, 3, :empty) == [
               [:empty, :empty, :empty],
               [:empty, :empty, :empty]
             ]
    end

    test "put and get" do
      board = Tiles.new(2, 3, :empty)

      board = Tiles.put(board, 0, 2, :wall)
      assert Tiles.get(board, 0, 2) == :wall
    end

    test "box" do
      board = Tiles.new(10, 10, :empty)

      board = Tiles.box(board, 4, 4, 2, 2, :wall)

      assert Tiles.get(board, 3, 4) == :empty
      assert Tiles.get(board, 4, 3) == :empty

      assert Tiles.get(board, 4, 4) == :wall
      assert Tiles.get(board, 4, 5) == :wall
      assert Tiles.get(board, 5, 4) == :wall
      assert Tiles.get(board, 5, 5) == :wall

      assert Tiles.get(board, 5, 6) == :empty
      assert Tiles.get(board, 6, 5) == :empty
    end
  end
end
