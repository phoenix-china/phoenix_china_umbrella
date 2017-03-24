defmodule PhoenixChina.Application do
  @moduledoc """
  The PhoenixChina Application Service.

  The phoenix_china system business domain lives in this application.

  Exposes API to clients such as the `PhoenixChina.Web` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link([
      worker(PhoenixChina.Repo, []),
    ], strategy: :one_for_one, name: PhoenixChina.Supervisor)
  end
end
