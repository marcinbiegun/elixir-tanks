defmodule TanksGame.Supervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children = [
      %{
        id: TanksGame.Server,
        start: {TanksGame.Server, :start_link, [{:hello}]}
      }
      # , %{
      #   id: TanksGamae.PlayersDynamicSupervisor,
      #   start: {TanksGame.PlayersDynamicSupervisor, :start_link, []}
      # }
    ]

    opts = [strategy: :one_for_all, max_restarts: 3, max_seconds: 3]

    Supervisor.init(children, opts)
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
