defmodule TanksWeb.GameController do
  use TanksWeb, :controller

  def index(conn, _params) do
    games = [
      %{id: 123}
    ]

    render(conn, "index.html", games: games)
  end

  # def create(conn, _params) do
  # end

  def show(conn, _params) do
    game = %{id: 123}

    render(conn, "show.html", game: game)
  end
end
