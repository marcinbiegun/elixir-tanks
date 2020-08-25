defmodule Tanks.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    IO.puts("Tanks.Application.start")

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
      {TanksGame.Supervisor, []},
      {Registry, [keys: :unique, name: :servers_registry]}
    ]

    init_ecs()

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

  defp init_ecs() do
    # Initialize registries
    ECS.Registry.Component.start()
    ECS.Registry.Entity.start()
    ECS.Registry.Id.start()
    ECS.Registry.ComponentTuple.start()

    # Initialize systems

    TanksGame.System.Velocity.component_types()
    |> ECS.Registry.ComponentTuple.build_registry_id()
    |> ECS.Registry.ComponentTuple.init_register_type()

    TanksGame.System.Movement.component_types()
    |> ECS.Registry.ComponentTuple.build_registry_id()
    |> ECS.Registry.ComponentTuple.init_register_type()
  end
end
