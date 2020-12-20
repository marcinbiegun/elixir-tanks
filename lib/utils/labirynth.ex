defmodule Utils.Labirynth do
  alias Utils.Tiles

  @empty :empty

  def generate(width, height) do
    init_x = 0
    init_y = 0

    steps = width * height - 1
    init_tiles = Tiles.new(width, height, @empty)
    init_tiles = Tiles.put(init_tiles, init_x, init_y, 0)
    next_number = 1

    put_path(init_tiles, steps, next_number, {0, 0})
  end

  def put_path(tiles, 0, _next_number, _last_coord) do
    tiles
  end

  def put_path(tiles, steps_left, next_number, {last_x, last_y} = _last_coord) do
    # IO.puts("\n")
    # IO.puts("#{steps_left}, #{next_number}, {#{last_x},#{last_y}}")
    # display_tiles(tiles)

    last_number = Tiles.get(tiles, last_x, last_y)

    top_coord = {last_x, last_y + 1}
    right_coord = {last_x + 1, last_y}
    bottom_coord = {last_x, last_y - 1}
    left_coord = {last_x - 1, last_y}

    top = Tiles.safe_get(tiles, top_coord)
    right = Tiles.safe_get(tiles, right_coord)
    bottom = Tiles.safe_get(tiles, bottom_coord)
    left = Tiles.safe_get(tiles, left_coord)

    possible = []
    possible = if top == @empty, do: [:top | possible], else: possible
    possible = if right == @empty, do: [:right | possible], else: possible
    possible = if bottom == @empty, do: [:bottom | possible], else: possible
    possible = if left == @empty, do: [:left | possible], else: possible

    # Need to go back and try again
    if Enum.empty?(possible) do
      smallest_neighbour_coord = Tiles.find(tiles, last_number - 1)

      # last = Tiles.safe_get(tiles, last_coord)
      # IO.puts(
      #   "going from #{inspect(last_coord)} (#{last}) to #{inspect(smallest_neighbour_coord)} (#{
      #     last_number - 1
      #   })"
      # )

      # Nunmber not put, go back
      put_path(tiles, steps_left, next_number, smallest_neighbour_coord)
      # raise "NO WAY"
    else
      pick = Enum.random(possible)

      {tiles, coord} =
        case pick do
          :top ->
            {Tiles.put(tiles, last_x, last_y + 1, next_number), {last_x, last_y + 1}}

          :right ->
            {Tiles.put(tiles, last_x + 1, last_y, next_number), {last_x + 1, last_y}}

          :bottom ->
            {Tiles.put(tiles, last_x, last_y - 1, next_number), {last_x, last_y - 1}}

          :left ->
            {Tiles.put(tiles, last_x - 1, last_y, next_number), {last_x - 1, last_y}}
        end

      # Number put!
      put_path(tiles, steps_left - 1, next_number + 1, coord)
    end
  end

  # defp display_tiles(tiles) do
  #   max_x = (tiles |> length()) - 1
  #   max_y = (tiles |> Enum.at(0) |> length()) - 1

  #   for y <- 0..max_y, x <- 0..max_x do
  #     c = Tiles.get(tiles, x, y)
  #     IO.write(" #{c} ")
  #     if x == max_x, do: IO.write("\n")
  #   end
  # end
end
