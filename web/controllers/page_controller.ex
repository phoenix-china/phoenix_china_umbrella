defmodule PhoenixChina.PageController do
  use PhoenixChina.Web, :controller
  alias PhoenixChina.Post
  alias PhoenixChina.User

  plug PhoenixChina.GuardianPlug

  def index(conn, params) do
    page = (from Post, order_by: [desc: :inserted_at], preload: [:user])
    |> Repo.paginate(params)

    render conn, "index.html",
      posts: page.entries,
      page: page
  end
end
