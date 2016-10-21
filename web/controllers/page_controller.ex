defmodule PhoenixChina.PageController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.{User, Post, Comment, PostLabel}

  def index(conn, %{"label" => label} = params) do
    query = Post
    |> order_by(desc: :is_top, desc: :latest_comment_inserted_at)
    |> preload([:label, :user, :latest_comment, latest_comment: :user])

    query = case PostLabel |> Repo.get_by(content: label) do
      nil -> query
      label_res -> query |> where(label_id: ^label_res.id)
    end

    pagination = query
    |> Repo.paginate(params)

    labels = PostLabel
    |> where(is_hide: false)
    |> order_by(:order)
    |> Repo.all

    user_count = Repo.one(from u in User, select: count(u.id))
    post_count = Repo.one(from p in Post, select: count(p.id))
    comment_count = Repo.one(from c in Comment, select: count(c.id))

    conn
    |> assign(:current_label, label)
    |> assign(:labels, labels)
    |> assign(:pagination, pagination)
    |> assign(:user_count, user_count)
    |> assign(:post_count, post_count)
    |> assign(:comment_count, comment_count)
    |> render("index.html")
  end

  def index(conn, _params) do
    index(conn, %{"label" => "全部"})
  end
end
