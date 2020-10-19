defmodule TanksWeb.GameController do
  use TanksWeb, :controller

  def index(conn, _params) do
    games = Tanks.GameServer.all()
    render(conn, "index.html", games: games)
  end

  def show(conn, %{"id" => game_id} = _params) do
    game = Tanks.GameServer.get(game_id)
    render(conn, "show.html", game: game)
  end

  def create(conn, _params) do
    game_id = Utils.Crypto.random_id()
    Tanks.GameServer.create(game_id)
    conn |> redirect(to: "/games") |> halt()
  end

  def delete(conn, %{"id" => game_id} = _params) do
    Tanks.GameServer.delete(game_id)
    conn |> redirect(to: "/games") |> halt()
  end
end
