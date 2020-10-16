defmodule Tanks.Game.Supervisor do
  use DynamicSupervisor

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_game(game_id) do
    DynamicSupervisor.start_child(
      __MODULE__,
      %{id: game_id, start: {Tanks.Game.Server, :start_link, [game_id]}, restart: :transient}
    )
  end

  def kill_children do
    Supervisor.which_children(__MODULE__)
    |> Enum.each(fn {_, child_pid, _, _} ->
      Process.exit(child_pid, :kill)
    end)
  end

  def count_children do
    Supervisor.count_children(__MODULE__)
  end
end
