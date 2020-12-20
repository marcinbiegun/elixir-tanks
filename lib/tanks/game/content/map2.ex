defmodule Tanks.Game.Content.Map2 do
  alias Utils.Tiles
  alias Tanks.Game.Content.Config

  @block_size 6
  @blocks 3
  @width @block_size * @blocks
  @height @block_size * @blocks

  def generate_entities(_level \\ 1) do
    {tiles, meta_tiles} = generate_tiles()

    # Only one board is supported
    boards = [Tanks.Game.Entity.Board.new(tiles)]

    # walls1 =
    #   Enum.map(1..8, fn i ->
    #     Tanks.Game.Entity.Wall.new(150, 100 + i * 50)
    #   end)

    # walls2 =
    #   Enum.map(1..8, fn i ->
    #     Tanks.Game.Entity.Wall.new(550, 100 + i * 50)
    #   end)

    zombies = [
      Tanks.Game.Entity.Zombie.new(250, 250),
      Tanks.Game.Entity.Zombie.new(270, 250),
      Tanks.Game.Entity.Zombie.new(250, 270),
      Tanks.Game.Entity.Zombie.new(290, 250),
      Tanks.Game.Entity.Zombie.new(250, 290)
    ]

    meta_entities = create_meta_entities(meta_tiles)

    zombies ++ boards ++ meta_entities
  end

  # Used in mix task
  def generate_tiles do
    meta = []

    meta =
      meta
      |> insert_meta_tile(44, 44, :exit)
      |> insert_meta_tile(10, 3, :exit)
      |> insert_meta_tile(2, 2, :entry)

    lab = Utils.Labirynth.generate(@blocks, @blocks)
    IO.inspect(lab)

    blocks =
      for x <- 0..(@blocks - 1), y <- 0..(@blocks - 1) do
        {x, y}
      end

    tiles = Tiles.new(@width, @height, :empty)

    IO.inspect(blocks)

    tiles =
      Enum.reduce(blocks, tiles, fn {block_x, block_y}, tiles ->
        Tiles.border(
          tiles,
          block_x * @block_size,
          block_y * @block_size,
          @block_size,
          @block_size,
          :wall
        )
      end)

    # tiles =
    #   Tiles.new(@width, @height, :empty)
    #   # Top safe house
    #   |> Tiles.border(0, 0, 8, 4, :wall)
    #   |> Tiles.box(3, 3, 0, 2, :empty)
    #   # Horizontal walls
    #   |> Tiles.box(0, 7, 50, 1, :wall)
    #   |> Tiles.box(45, 7, 2, 1, :empty)
    #   # Horizontal walls
    #   |> Tiles.box(0, 11, 50, 1, :wall)
    #   |> Tiles.box(2, 11, 5, 1, :empty)
    #   # Boxes
    #   |> Tiles.box(5, 13, 8, 6, :wall)
    #   |> Tiles.box(30, 30, 8, 6, :wall)
    #   |> Tiles.box(7, 36, 8, 6, :wall)
    #   # Bottom safe house
    #   |> Tiles.border(40, 45, 8, 4, :wall)
    #   |> Tiles.box(43, 45, 1, 2, :empty)
    #   # Outer border
    #   |> Tiles.border(0, 0, @width, @height, :wall)

    {tiles, meta}
  end

  defp insert_meta_tile(list, x, y, type) do
    [{x * Config.tile_size(), y * Config.tile_size(), type} | list]
  end

  defp create_meta_entities(meta_tiles) do
    meta_tiles |> Enum.map(&create_meta_entity/1)
  end

  defp create_meta_entity({x, y, :exit}) do
    Tanks.Game.Entity.Exit.new(x, y)
  end

  defp create_meta_entity({x, y, :entry}) do
    Tanks.Game.Entity.Entry.new(x, y)
  end
end
