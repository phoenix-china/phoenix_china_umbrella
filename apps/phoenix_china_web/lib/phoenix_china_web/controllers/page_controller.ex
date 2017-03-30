defmodule PhoenixChina.Web.PageController do
  use PhoenixChina.Web, :controller

  def index(conn, _params) do
    IO.inspect System.get_env("MAILGUN_API_KEY")
    render conn, "index.html"
  end
end
