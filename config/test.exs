use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :phoenix_admin, PhoenixAdmin.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :phoenix_admin, PhoenixAdmin.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "phoenix",
  password: "verysecret",
  database: "phoenix_admin_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
