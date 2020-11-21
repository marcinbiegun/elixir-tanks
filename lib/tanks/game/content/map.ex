defmodule Tanks.Game.Content.Map do
  alias Utils.Tiles
  alias Tanks.Game.Content.Config

  @width 50
  @height 50

  def generate_entities(_level \\ 1) do
    {tiles, meta_tiles} = generate_tiles()
    boards = [Tanks.Game.Entity.Board.new(tiles)]

    walls1 =
      Enum.map(1..8, fn i ->
        Tanks.Game.Entity.Wall.new(150, 100 + i * 50)
      end)

    walls2 =
      Enum.map(1..8, fn i ->
        Tanks.Game.Entity.Wall.new(550, 100 + i * 50)
      end)

    zombies = [
      Tanks.Game.Entity.Zombie.new(250, 250),
      Tanks.Game.Entity.Zombie.new(270, 250),
      Tanks.Game.Entity.Zombie.new(250, 270),
      Tanks.Game.Entity.Zombie.new(290, 250),
      Tanks.Game.Entity.Zombie.new(250, 290)
    ]

    meta_entities = create_meta_entities(meta_tiles)

    walls1 ++ walls2 ++ zombies ++ boards ++ meta_entities
  end

  # Used in mix task
  def generate_tiles do
    meta = []

    meta =
      meta
      |> insert_meta_tile(44, 44, :map_exit)
      |> insert_meta_tile(10, 3, :map_exit)

    tiles =
      Tiles.new(@width, @height, :empty)
      # Top safe house
      |> Tiles.border(0, 0, 8, 4, :wall)
      |> Tiles.box(3, 3, 0, 2, :empty)
      # Horizontal walls
      |> Tiles.box(0, 7, 50, 1, :wall)
      |> Tiles.box(45, 7, 2, 1, :empty)
      # Horizontal walls
      |> Tiles.box(0, 11, 50, 1, :wall)
      |> Tiles.box(2, 11, 5, 1, :empty)
      # Boxes
      |> Tiles.box(5, 13, 8, 6, :wall)
      |> Tiles.box(30, 30, 8, 6, :wall)
      |> Tiles.box(7, 36, 8, 6, :wall)
      # Bottom safe house
      |> Tiles.border(40, 45, 8, 4, :wall)
      |> Tiles.box(43, 45, 1, 2, :empty)
      # Outer border
      |> Tiles.border(0, 0, @width, @height, :wall)

    {tiles, meta}
  end

  defp insert_meta_tile(list, x, y, type) do
    [{x * Config.tile_size(), y * Config.tile_size(), type} | list]
  end

  defp create_meta_entities(meta_tiles) do
    meta_tiles |> Enum.map(&create_meta_entity/1)
  end

  defp create_meta_entity({x, y, :map_exit}) do
    Tanks.Game.Entity.Exit.new(x, y)
  end
end
