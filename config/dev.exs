use Mix.Config

config :phoenix_china,
  cookie_sign_salt: "676NfJkO"

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :phoenix_china, PhoenixChina.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/webpack/bin/webpack.js", "--watch", "--colors", "--progress",
                    cd: Path.expand("../", __DIR__)]]


# Watch static and templates for browser reloading.
config :phoenix_china, PhoenixChina.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :phoenix_china, PhoenixChina.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "phoenix_china_dev",
  hostname: "localhost",
  pool_size: 10

# 开发环境下github配置，与生产环境不同
config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: "ad4e4ead45b08891286f",
  client_secret: "17b9d84b64ff5432ed7dc01308a428718f546de8"
