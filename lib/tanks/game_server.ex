defmodule Tanks.GameServer do
  @moduledoc """
  High level functions for operations on game servers.
  """

  def create(game_id) do
    Tanks.Game.ServerSupervisor.start_game_server(game_id)
  end

  def get(game_id) do
    Tanks.Game.Server.summary(game_id)
  end

  def all do
    Tanks.Game.Server.all_summaries()
  end

  def delete(game_id) do
    Tanks.Game.Server.stop(game_id)
  end

  def join_player(game_id, token) do
    Tanks.Game.Server.join_player(game_id, token)
  end
end
