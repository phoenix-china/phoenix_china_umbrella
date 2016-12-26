defmodule PhoenixChina.Guardian.CurrentUser do
  import Plug.Conn, only: [assign: 3]
  
  def init(opts \\ %{}), do: Enum.into(opts, %{})

  def call(conn, opts) do
    key = Map.get(opts, :key, :default)
    
    conn
    |> assign(:authenticated?, Guardian.Plug.authenticated?(conn, key))
    |> assign(:current_user, Guardian.Plug.current_resource(conn, key))
  end
end