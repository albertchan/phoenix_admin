# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :phoenix_admin,
  adapter: Bamboo.LocalAdapter,
  ecto_repos: [PhoenixAdmin.Repo]

# Configures the mailer
config :phoenix_admin, PhoenixAdmin.Mailer,
  adapter: Bamboo.LocalAdapter

# Configures the endpoint
config :phoenix_admin, PhoenixAdmin.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "8E+JYhhBWFGp5zNnYHDSOPosi+YZ4UU10rMlTnxxbohiMqo+aBUzWV3Q/GySIcjl",
  render_errors: [view: PhoenixAdmin.ErrorView, accepts: ~w(json json-api)],
  pubsub: [name: PhoenixAdmin.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :format_encoders,
  "json-api": Poison

config :mime, :types, %{
  "application/vnd.api+json" => ["json-api"]
}

# Guardian authentication framework https://github.com/ueberauth/guardian
config :guardian, Guardian,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT,  # optional
  hooks: GuardianDb,
  issuer: "PhoenixAdmin.#{Mix.env}",
  ttl: { 30, :days },
  verify_issuer: true, # optional
  secret_key: "ddD/iiwFX34H31KEb55Hw8vMp9PZgwn6YM6n4cYhq80ghwcch7TCkVYSW6Toyjvq",
  serializer: PhoenixAdmin.GuardianSerializer

config :guardian_db, GuardianDb,
  repo: PhoenixAdmin.Repo,
  schema_name: "tokens", # optional, default is "guardian_tokens"
  sweep_interval: 120 # minutes

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
