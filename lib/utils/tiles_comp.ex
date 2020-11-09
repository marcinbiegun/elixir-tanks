defmodule Utils.TilesComp do
  @moduledoc """
  Modules for computations on tile boars in relation to non-tileable {x, y} coords.
  `{x, y} = {0, 0}` is top right
  positive `x` means going down
  positive `y` means going right
  """

  # TODO: use shape
  def collides?(tiles, tile_size, collidable_tiles, pos_x, pos_y, shape) do
    tile_x = div(round(pos_x), round(tile_size))
    tile_y = div(round(pos_y), round(tile_size))

    tile_coords =
      for x <- [tile_x - 1, tile_x, tile_x + 1],
          y <- [tile_y - 1, tile_y, tile_y + 1],
          do: {x, y}

    Enum.any?(tile_coords, fn {x, y} ->
      Utils.Tiles.get(tiles, x, y) in collidable_tiles and
        Utils.Math.collision?(
          x * tile_size,
          y * tile_size,
          {:rectangle, tile_size},
          pos_x,
          pos_y,
          shape
        )
    end)
  end
end
