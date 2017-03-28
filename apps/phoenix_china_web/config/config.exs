# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :phoenix_china_web,
  namespace: PhoenixChina.Web,
  ecto_repos: [PhoenixChina.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :phoenix_china_web, PhoenixChina.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "7acxPCnXriX+azjIvqGSfkRy0s4JMwVyJP+F7ygZPHc8xuq42diq3DvUsT7ulSxg",
  render_errors: [view: PhoenixChina.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PhoenixChina.Web.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configures Guardian
config :guardian, Guardian,
  allowed_algos: ["HS512"],
  verify_module: Guardian.JWT,
  issuer: "PhoenixChina",
  ttl: { 30, :days },
  allowed_drift: 2000,
  verify_issuer: true,
  secret_key: "z4pyE6JoizjOGkhvak7XVEG+vmVYA6072W4HZzCuuY+CXQzbDwkviYpWurq83tef",
  serializer: PhoenixChina.Guardian.Serializer

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
