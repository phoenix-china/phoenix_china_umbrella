use Mix.Config

# Configure your database
config :phoenix_china, PhoenixChina.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "phoenix_china_dev",
  hostname: "localhost",
  pool_size: 10
