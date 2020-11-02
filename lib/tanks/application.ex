defmodule Tanks.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      ## Phoenix processes
      # Start the Ecto repository
      Tanks.Repo,
      # Start the Telemetry supervisor
      TanksWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Tanks.PubSub},
      # Start the Endpoint (http/https)
      TanksWeb.Endpoint,
      #
      ## Our processes
      %{id: ECS.Registry.Id, start: {ECS.Registry.Id, :start, []}},
      {Tanks.Game.ServerSupervisor, []},
      {Registry, [keys: :unique, name: Registry.Tanks.Game.Server]},
      {Registry, [keys: :unique, name: Registry.ECS.Registry.Component]},
      {Registry, [keys: :unique, name: Registry.ECS.Registry.ComponentTuple]},
      {Registry, [keys: :unique, name: Registry.ECS.Registry.Entity]},
      {Registry, [keys: :unique, name: Registry.ECS.Queue]},
      {Registry, [keys: :unique, name: Registry.ECS.Cache]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tanks.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TanksWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
