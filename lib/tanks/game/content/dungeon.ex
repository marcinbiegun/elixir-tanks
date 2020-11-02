defmodule Tanks.Game.Content.Dungeon do
  @moduledoc """
  Based on https://www.gamasutra.com/blogs/AAdonaac/20150903/252889/Procedural_Dungeon_Generation_Algorithm.php
  """

  alias Utils.Tiles

  def generate_tiles do
    board = Tiles.new(50, 50, :empty)
    board = Tiles.box(board, 10, 10, 1, 1, :wall)
    # board = Tiles.box(board, 12, 10, 2, 2, :wall)
    # board = Tiles.box(board, 15, 10, 3, 3, :wall)
    board
  end
end
