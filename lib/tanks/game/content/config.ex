defmodule Tanks.Game.Content.Config do
  @tile_size 32.0
  @tiles %{
    empty: %{name: :empty, collidable: false, ascii: " "},
    wall: %{name: :wall, collidable: true, ascii: "#"}
  }

  def tile_entity_type, do: Tanks.Game.Entity.Board

  def tile_size, do: @tile_size

  def tile(type), do: @tiles[type][:name]
  def ascii_tile(type), do: @tiles[type][:ascii]

  def collidable_tiles() do
    @tiles
    |> Enum.filter(fn {_id, tile} -> tile[:collidable] end)
    |> Enum.map(fn {_id, tile} -> tile[:name] end)
  end
end
