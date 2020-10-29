defmodule Tanks.Game.Content.Level do
  def create_level_entities() do
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

    tiles = Tanks.Game.Content.Dungeon.generate_tiles()
    boards = [Tanks.Game.Entity.Board.new(tiles)]

    walls1 ++ walls2 ++ zombies ++ boards
  end
end
