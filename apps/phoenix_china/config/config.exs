use Mix.Config

config :phoenix_china, ecto_repos: [PhoenixChina.Repo]

# Configure phoenix generators
config :phoenix, :generators,
  binary_id: true

import_config "#{Mix.env}.exs"
