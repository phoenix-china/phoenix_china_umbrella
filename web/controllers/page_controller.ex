defmodule PhoenixChina.PageController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.{User, Post, Comment, PostLabel}

  plug :load
  defp load(conn, _params) do
    user_count = Repo.one(from u in User, select: count(u.id))
    post_count = Repo.one(from p in Post, select: count(p.id))
    comment_count = Repo.one(from c in Comment, select: count(c.id))

    conn
    |> assign(:user_count, user_count)
    |> assign(:post_count, post_count)
    |> assign(:comment_count, comment_count)
  end

  def index(conn, %{"label" => label} = params) do
    {conn, query} = 
      case PostLabel |> Repo.get_by(content: label) do
        nil -> {conn, Post}
        label -> 
          query = 
            Post 
            |> where(label_id: ^label.id)

          count = 
            Repo.one(from p in query, select: count(p.id, :distinct))
          
          conn =
            conn
            |> assign(:label, label)
            |> assign(:for_label_count, count)

          {conn, query}
      end

    pagination = 
      query
      |> order_by(desc: :is_top, desc: :latest_comment_inserted_at)
      |> preload([:label, :user, :latest_comment, latest_comment: :user])
      |> Repo.paginate(params)

    conn
    |> assign(:pagination, pagination)
    |> render("index.html")
  end

  def index(conn, params) do
    params =
      params
      |> Map.put_new("label", "全部")

    index(conn, params)
  end

  def last(conn, params) do
    pagination =
      Post
      |> order_by(desc: :inserted_at)
      |> preload([:label, :user, :latest_comment, latest_comment: :user])
      |> Repo.paginate(params)

    conn
    |> assign(:pagination, pagination)
    |> render("index.html")
  end

  def noreply(conn, params) do
    pagination =
      Post
      |> where([p], p.comment_count <= 0)
      |> order_by(desc: :inserted_at)
      |> preload([:label, :user, :latest_comment, latest_comment: :user])
      |> Repo.paginate(params)

    conn
    |> assign(:pagination, pagination)
    |> render("index.html")
  end
end
