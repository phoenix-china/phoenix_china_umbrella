defmodule PhoenixChina.Guardian.CurrentUser do
  import Plug.Conn, only: [assign: 3]
  
  def init(opts \\ %{}), do: Enum.into(opts, %{})

  def call(conn, opts) do
    key = Map.get(opts, :key, :default)
    
    case Guardian.Plug.authenticated?(conn, key) do
      true ->
        current_user = Guardian.Plug.current_resource(conn, key)

        conn
        |> assign(:authenticated?, true)
        |> assign(:current_user, current_user)

      false ->
        current_user = nil

        conn
        |> assign(:authenticated?, false)
        |> assign(:current_user, current_user)
    end
  end
end