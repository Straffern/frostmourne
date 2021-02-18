# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :frostmourne,
  ecto_repos: [Frostmourne.Repo]

# Configures the endpoint
config :frostmourne, FrostmourneWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ANAFE61Z7Xm+2NvpHDb5s8cwYOOGuc5OlNFv17Pb+sJ5JgAhTAYUEnozvTKtMHJc",
  render_errors: [view: FrostmourneWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Frostmourne.PubSub,
  live_view: [signing_salt: "R73Kyqs3"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
