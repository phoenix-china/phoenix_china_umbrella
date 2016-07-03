defmodule PhoenixChina.PageController do
  use PhoenixChina.Web, :controller
  alias PhoenixChina.Post
  
  plug PhoenixChina.GuardianPlug

  def index(conn, _params) do
    posts = (from Post, order_by: [desc: :inserted_at], preload: [:user])
    |> Repo.all
    render conn, "index.html", posts: posts
  end
end
