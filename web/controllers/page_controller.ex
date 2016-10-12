defmodule PhoenixChina.PageController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.{Post, PostLabel}

  def index(conn, %{"label" => label} = params) do
    query = Post
    |> order_by(desc: :is_top, desc: :latest_comment_inserted_at)
    |> preload([:label, :user, :latest_comment, latest_comment: :user])

    query = case PostLabel |> Repo.get_by(content: label) do
      nil ->
        query

      label_res ->
        query |> where(label_id: ^label_res.id)
    end

    pagination = query |> Repo.paginate(params)

    labels = PostLabel |> where(is_hide: false) |> order_by(:order) |> Repo.all

    render conn, "index.html",
      current_label: label,
      labels: labels,
      pagination: pagination
  end

  def index(conn, _params) do
    index(conn, %{"label" => "全部"})
  end
end
