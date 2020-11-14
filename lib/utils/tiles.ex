defmodule Utils.Tiles do
  @moduledoc """
  `{x, y} = {0, 0}` is top right
  positive `x` means going down
  positive `y` means going right
  """

  def new(width, height, value) do
    Enum.map(1..width, fn _x ->
      Enum.map(1..height, fn _y -> value end)
    end)
  end

  def box(tiles, start_x, start_y, size_x, size_y, value) do
    {max_x, max_y} = max_coords(tiles)

    Enum.flat_map(start_x..(start_x + size_x - 1), fn x ->
      Enum.map(start_y..(start_y + size_y - 1), fn y -> {x, y} end)
    end)
    |> Enum.reject(fn {x, y} -> x > max_x or y > max_y end)
    |> Enum.reduce(tiles, fn {x, y}, acc ->
      put(acc, x, y, value)
    end)
  end

  def border(tiles, start_x, start_y, size_x, size_y, value) do
    {max_x, max_y} = max_coords(tiles)

    Enum.flat_map(start_x..(start_x + size_x - 1), fn x ->
      Enum.map(start_y..(start_y + size_y - 1), fn y ->
        if x == start_x or x == start_x + size_x - 1 or y == start_y or y == start_y + size_y - 1 do
          {x, y}
        else
          nil
        end
      end)
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.reject(fn {x, y} -> x > max_x or y > max_y end)
    |> Enum.reduce(tiles, fn {x, y}, acc ->
      put(acc, x, y, value)
    end)
  end

  def put(tiles, x, y, val) do
    {max_x, max_y} = max_coords(tiles)

    if x > max_x or y > max_y do
      val
    else
      List.replace_at(tiles, x, List.replace_at(Enum.at(tiles, x), y, val))
    end
  end

  def get(tiles, x, y) do
    Enum.at(tiles, x, []) |> Enum.at(y, nil)
  end

  def max_coords(tiles) do
    max_x = (tiles |> length()) - 1
    max_y = (tiles |> Enum.at(0) |> length()) - 1
    {max_x, max_y}
  end
end
