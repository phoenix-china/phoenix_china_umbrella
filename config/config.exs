# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :phoenix_china,
  ecto_repos: [PhoenixChina.Repo]

# Configures the endpoint
config :phoenix_china, PhoenixChina.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "A14PW9EBmSkhKBmbaSY3UoJDME8Pb/LP0B3yLVv34K0O1UfzSoDb4X7+RK0AET01",
  render_errors: [view: PhoenixChina.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PhoenixChina.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :guardian, Guardian,
  issuer: "PhoenixChina.#{Mix.env}",
  ttl: { 30, :days },
  verify_issuer: true,
  secret_key: to_string(Mix.env),
  serializer: PhoenixChina.GuardianSerializer

config :scrivener_html,
  routes_helper: PhoenixChina.Router.Helpers

config :ueberauth, Ueberauth,
  providers: [
    github: { Ueberauth.Strategy.Github, [] },
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
import_config "config.secret.exs"
