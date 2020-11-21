defmodule Mix.Tasks.GenerateDungeon do
  use Mix.Task

  alias Tanks.Game.Content
  alias Utils.Tiles

  # def run([source_slug]) do
  #   Mix.Task.run("app.start")
  #   Scrap.Crawl.Worker.RefreshOffers.run(source_slug)
  # end

  @impl Mix.Task
  def run([]) do
    {tiles, _meta} = Tanks.Game.Content.Map.generate_tiles()
    display_tiles(tiles)
  end

  defp display_tiles(tiles) do
    max_x = (tiles |> length()) - 1
    max_y = (tiles |> Enum.at(0) |> length()) - 1

    for y <- 0..max_y, x <- 0..max_x do
      Tiles.get(tiles, x, y) |> Content.Config.ascii_tile() |> IO.write()
      if x == max_x, do: IO.write("\n")
    end
  end
end
