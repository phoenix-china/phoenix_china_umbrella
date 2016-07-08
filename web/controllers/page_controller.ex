defmodule PhoenixChina.PageController do
  use PhoenixChina.Web, :controller
  alias PhoenixChina.Post

  plug PhoenixChina.GuardianPlug

  def index(conn, params) do
    page = (from Post, order_by: [desc: :inserted_at],
    preload: [:user, :latest_comment, latest_comment: :user])
    |> Repo.paginate(params)

    render conn, "index.html",
      posts: page.entries,
      page: page
  end

  def room(conn, _params) do
    render conn, "room.html",
      layout: {PhoenixChina.LayoutView, "room.html"}
  end
end
