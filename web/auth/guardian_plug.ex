defmodule PhoenixChina.GuardianPlug do
  import PhoenixChina.ViewHelpers, only: [logged_in?: 1, current_user: 1]

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> Plug.Conn.assign(:logged_in, logged_in?(conn))
    |> Plug.Conn.assign(:current_user, current_user(conn))
  end
end
