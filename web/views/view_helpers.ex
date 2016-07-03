defmodule PhoenixChina.ViewHelpers do
  def logged_in?(conn) do
    Guardian.Plug.authenticated?(conn)
  end

  def current_user(conn) do
    Guardian.Plug.current_resource(conn)
  end

  def admin_logged_in?(conn) do
    Guardian.Plug.authenticated?(conn, :admin)
  end

  def admin_user(conn) do
    Guardian.Plug.current_resource(conn, :admin)
  end
end
