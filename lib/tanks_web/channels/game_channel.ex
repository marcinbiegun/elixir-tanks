defmodule TanksWeb.GameChannel do
  use TanksWeb, :channel

  def join("game:" <> game_id_str, _params, socket) do
    {game_id, ""} = Integer.parse(game_id_str)

    # Assign data to channel
    new_game = %{id: game_id}
    socket = assign(socket, :game, new_game)

    # Start game server
    response =
      case TanksGame.Supervisor.start_game(game_id) do
        {:ok, _pid} ->
          %{id: game_id, msg: "Created a new game"}

        {:error, {:already_started, _pid}} ->
          %{id: game_id, msg: "Joined existing game"}

        _ ->
          %{error: "error"}
      end

    # Respond
    {:ok, response, socket}
  end

  def handle_in("input", data, socket) do
    # broadcast!(socket, "new_msg", %{body: body})
    IO.inspect(data)
    {:noreply, socket}
  end
end
