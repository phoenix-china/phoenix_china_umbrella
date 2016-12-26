defmodule PhoenixChina.Guardian.CurrentUser do
  import Plug.Conn, only: [assign: 3]
  
  def init(opts \\ %{}), do: Enum.into(opts, %{})

  def call(conn, opts) do
    key = Map.get(opts, :key, :default)

    conn
    |> assign(gen_key(key, :authenticated?), Guardian.Plug.authenticated?(conn, key))
    |> assign(gen_key(key, :current_user), Guardian.Plug.current_resource(conn, key))
  end

  defp gen_key(key, name) do
    (if key != :default, do: to_string(key) <> "_", else: "")
    |> join(to_string(name))
    |> String.to_atom
  end

  defp join(a, b) when is_binary(a) and is_binary(b) do
    a <> b
  end
end