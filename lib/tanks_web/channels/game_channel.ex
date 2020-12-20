defmodule TanksWeb.GameChannel do
  use TanksWeb, :channel
  require Logger

  def join("game:" <> game_id, %{"playerToken" => player_token} = _params, socket) do
    # Join game server
    {response, socket} =
      with {:ok, server} <- Tanks.GameServer.get(game_id),
           {:ok, player} <- Tanks.GameServer.add_player(game_id, player_token),
           {:ok, init_state} <- Tanks.GameServer.init_state(game_id) do
        # Assign data to channel
        socket = assign(socket, :current_server, %{game_id: server.game_id, player_id: player.id})

        :ok =
          Tanks.ChannelWatcher.monitor(
            :game,
            self(),
            {__MODULE__, :leave, [game_id, player.id, player_token]}
          )

        response = %{
          game_id: server.game_id,
          player_id: player.id,
          msg: "Joined game #{game_id}",
          init_state: init_state
        }

        {response, socket}
      else
        error ->
          response = %{msg: "Unable to join game #{game_id}: #{inspect(error)}"}
          {response, socket}
      end

    # Respond
    {:ok, response, socket}
  end

  def leave(game_id, player_id, _player_token) do
    with {:ok, _server} <- Tanks.GameServer.get(game_id) do
      # {:ok, _player} <- Tanks.GameServer.get_player(game_id, player_id) do
      Tanks.GameServer.remove_player(game_id, player_id)
    end
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
        "admin_input",
        %{"type" => type} = data,
        socket
      ) do
    %{game_id: game_id} = socket.assigns.current_server

    Logger.debug("Handling admin_input: #{type}")

    case type do
      "next_map" ->
        Tanks.GameServer.next_map(game_id)

      "restart_map" ->
        Tanks.GameServer.restart_map(game_id)

      "restart_game" ->
        Tanks.GameServer.restart_game(game_id)

      _other ->
        Logger.warn("Unknown admin_input: #{inspect(data)})")
    end

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
