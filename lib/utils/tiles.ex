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

  def box(board, start_x, start_y, size_x, size_y, value) do
    Enum.flat_map(start_x..(start_x + size_x - 1), fn x ->
      Enum.map(start_y..(start_y + size_y - 1), fn y -> {x, y} end)
    end)
    |> Enum.reduce(board, fn {x, y}, acc ->
      put(acc, x, y, value)
    end)
  end

  def put(board, x, y, val) do
    List.replace_at(board, x, List.replace_at(Enum.at(board, x), y, val))
  end

  def get(board, x, y) do
    Enum.at(board, x) |> Enum.at(y)
  end
end
