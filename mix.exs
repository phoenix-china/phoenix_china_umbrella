defmodule PhoenixChina.Mixfile do
  use Mix.Project

  def project do
    [app: :phoenix_china,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {PhoenixChina, []},
     applications: [:phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger,
      :gettext, :phoenix_ecto, :postgrex, :comeonin, :guardian, :scrivener, :scrivener_ecto, 
      :scrivener_html, :timex, :timex_ecto, :ueberauth_github, :con_cache, :qiniu, :hashids, 
      :aliyun_direct_mail, :phoenix_html_sanitizer, :logger_file_backend]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.2.1"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:comeonin, "~> 2.5"},
      {:guardian, "~> 0.12.0"},
      {:scrivener, "~> 2.0"},
      {:scrivener_ecto, "~> 1.0"},
      {:scrivener_html, "~> 1.1"},
      {:timex, "~> 3.0"},
      {:timex_ecto, "~> 3.0"},
      {:ueberauth_github, "~> 0.2"},
      {:con_cache, "~> 0.11.1"},
      {:qiniu, "~> 0.3.0"},
      {:hashids, "~> 2.0"},
      {:aliyun_direct_mail, github: "nanlong/aliyun-direct-mail"},
      {:phoenix_html_sanitizer, "~> 1.0.0"},
      {:logger_file_backend, "~> 0.0.9"},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
