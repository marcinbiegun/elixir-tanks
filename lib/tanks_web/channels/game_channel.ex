defmodule TanksWeb.GameChannel do
  use TanksWeb, :channel

  def join("game:" <> game_id_str, _params, socket) do
    {game_id, ""} = Integer.parse(game_id_str)

    # Assign data to channel
    game = %{id: game_id}
    socket = assign(socket, :current_game, game)

    # Start game server
    response =
      case TanksGame.Supervisor.start_game(game_id) do
        {:ok, _pid} ->
          %{id: game_id, msg: "Created a new game"}

        {:error, {:already_started, _pid}} ->
          %{id: game_id, msg: "Joined existing game"}

        error ->
          %{error: "Unable to start game server"}
      end

    # Respond
    {:ok, response, socket}
  end

  def handle_in(
        "input",
        %{"left" => left, "right" => right, "up" => up, "down" => down} = _data,
        socket
      ) do
    game_id = socket.assigns.current_game.id
    input = %{left: left, right: right, up: up, down: down}
    TanksGame.Server.send_input(game_id, input)

    {:noreply, socket}
  end

  def handle_in(
        "action",
        %{"type" => "fire", "x" => x, "y" => y} = _data,
        socket
      ) do
    game_id = socket.assigns.current_game.id
    TanksGame.Server.send_action(game_id, :fire, {x, y})

    {:noreply, socket}
  end
end
