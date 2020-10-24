defmodule TanksWeb.GameChannel do
  use TanksWeb, :channel

  def join("game:" <> game_id, %{"playerToken" => player_token} = _params, socket) do
    # Assign data to channel

    # Join game server
    {response, socket} =
      with {:ok, server} <- Tanks.GameServer.get(game_id),
           {:ok, player} <- Tanks.GameServer.join_player(game_id, player_token) do
        socket = assign(socket, :current_server, %{game_id: server.game_id, player_id: player.id})
        {%{game_id: server.game_id, player_id: player.id, msg: "Joined game #{game_id}"}, socket}
      else
        error ->
          {%{msg: "Unable to join game #{game_id}: #{inspect(error)}"}, socket}
      end

    # Respond
    {:ok, response, socket}
  end

  def handle_in(
        "input",
        %{"left" => left, "right" => right, "up" => up, "down" => down} = _data,
        socket
      ) do
    %{game_id: game_id, player_id: player_id} = socket.assigns.current_server
    input = %{left: left, right: right, up: up, down: down}
    Tanks.Game.Server.send_input(game_id, player_id, input)

    {:noreply, socket}
  end

  def handle_in(
        "action",
        %{"type" => "fire", "x" => x, "y" => y} = _data,
        socket
      ) do
    %{game_id: game_id, player_id: player_id} = socket.assigns.current_server
    Tanks.Game.Server.send_action(game_id, player_id, :fire, {x, y})

    {:noreply, socket}
  end
end
