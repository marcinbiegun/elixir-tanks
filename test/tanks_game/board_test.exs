defmodule Tanks.Game.BoardTest do
  use ExUnit.Case

  alias Utils.Board

  describe "tiles" do
    test "new" do
      assert Board.new(2, 3, :empty) == [
               [:empty, :empty, :empty],
               [:empty, :empty, :empty]
             ]
    end

    test "put and get" do
      board = Board.new(2, 3, :empty)

      board = Board.put(board, 0, 2, :wall)
      assert Board.get(board, 0, 2) == :wall
    end

    test "box" do
      board = Board.new(10, 10, :empty)

      board = Board.box(board, 4, 4, 2, 2, :wall)

      assert Board.get(board, 3, 4) == :empty
      assert Board.get(board, 4, 3) == :empty

      assert Board.get(board, 4, 4) == :wall
      assert Board.get(board, 4, 5) == :wall
      assert Board.get(board, 5, 4) == :wall
      assert Board.get(board, 5, 5) == :wall

      assert Board.get(board, 5, 6) == :empty
      assert Board.get(board, 6, 5) == :empty
    end
  end
end
