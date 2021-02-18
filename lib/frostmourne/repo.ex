defmodule Frostmourne.Repo do
  use Ecto.Repo,
    otp_app: :frostmourne,
    adapter: Ecto.Adapters.Postgres
end
