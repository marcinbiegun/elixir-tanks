defmodule Tanks.Game.Content.Config do
  @tile_size 32
  @tiles %{
    empty: :empty,
    wall: :wall
  }
  @ascii_tiles %{
    empty: " ",
    wall: "#"
  }

  def tile_size, do: @tile_size

  def tile(type), do: @tiles[type]
  def ascii_tile(type), do: @ascii_tiles[type]
end
