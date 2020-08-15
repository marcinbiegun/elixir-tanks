defmodule TanksWeb.GameChannel do
  use TanksWeb, :channel

  def join("game:" <> game_id, _params, socket) do
    new_game = %{id: game_id, name: "Ostra rozgrywka"}
    socket = assign(socket, :game, new_game)
    response = %{game: new_game}
    {:ok, response, socket}
  end
end
