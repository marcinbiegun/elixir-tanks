# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :tanks,
  # TODO: Make it not require psql database to run
  # ecto_repos: [Tanks.Repo]
  ecto_repos: []

# Configures the endpoint
config :tanks, TanksWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "TT78mQSi/3HFGIuskF4J5yS5w0djLMEKF83WNnzI1POAVqYN9UgQ5iLgoul62+7Y",
  render_errors: [view: TanksWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Tanks.PubSub,
  live_view: [signing_salt: "k0GK+AER"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
