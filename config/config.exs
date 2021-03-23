# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :griffin,
  ecto_repos: [Griffin.Repo]

# Configures the Repo for Lolth
config :griffin, :lolth,
  repo: Griffin.Repo,
  data_provider: Lolth.DataService.Provider.Default

config :tesla,
  adapter: Tesla.Adapter.Hackney

# Configures the endpoint
config :griffin, GriffinWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "XbO3CaJl9RkeJWg1cXUFt8CKiMj9m3kR0YilCN4buMfQGazZKKRQ0kVZD6zRXcIw",
  render_errors: [view: GriffinWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Griffin.PubSub,
  live_view: [signing_salt: "Tsli2Fka"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id],
  level: :info

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :griffin, Griffin.Auth.Guardian,
  issuer: "Griffin",
  secret_key: "o6v49BtbNqefG4o7nRBllq9fXKds9NYd9CZH/fhNuJa8GqVhHG4+TVxXhGg90era"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
