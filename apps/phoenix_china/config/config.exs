use Mix.Config

config :phoenix_china, ecto_repos: [PhoenixChina.Repo]

import_config "#{Mix.env}.exs"
