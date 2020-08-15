defmodule Tanks.Repo do
  use Ecto.Repo,
    otp_app: :tanks,
    adapter: Ecto.Adapters.Postgres
end
