defmodule Tanks.GameServer do
  @moduledoc """
  High level functions for operations on game servers.
  Web channels and controllers should only access those functions.
  """

  def create(game_id, level, opts \\ []) do
    Tanks.Game.ServerSupervisor.start_game_server(game_id, level, opts)
  end

  def get(game_id) do
    Tanks.Game.Server.summary(game_id)
  end

  def init_state(game_id) do
    Tanks.Game.Server.init_state(game_id)
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
