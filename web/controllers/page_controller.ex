defmodule PhoenixChina.PageController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.{Post, PostLabel}

  plug PhoenixChina.GuardianPlug

  def index(conn, %{"page" => page_num, "label" => label}) do
    page = ConCache.get_or_store(:phoenix_china, "page_index:#{label}-page:#{page_num}", fn() ->
      query = Post
      |> order_by(desc: :is_top, desc: :latest_comment_inserted_at)
      |> preload([:label, :user, :latest_comment, latest_comment: :user])

      query = case PostLabel |> Repo.get_by(content: label) do
        nil ->
          query

        label_res ->
          query |> where(label_id: ^label_res.id)
      end

      query |> Repo.paginate(%{"page" => page_num})
    end)

    post_list_html = ConCache.get_or_store(:phoenix_china, "page_index:#{label}-html:#{page_num}", fn() ->
      Phoenix.View.render_to_string(PhoenixChina.PostView, "entries.html", %{conn: conn, page: page})
    end)

    labels = PostLabel |> Repo.all

    render conn, "index.html",
      post_list_html: post_list_html,
      page: page,
      labels: labels
  end

  def index(conn, params) do
    params = case Map.has_key?(params, "page") do
      true -> params
      false -> Map.put_new(params, "page", "1")
    end

    params = case Map.has_key?(params, "label") do
      true -> params
      false -> Map.put_new(params, "label", "全部")
    end 

    index(conn, params)
  end

  def room(conn, _params) do
    render conn, "room.html",
      layout: {PhoenixChina.LayoutView, "room.html"}
  end

  def commits(conn, _params) do
    conn = assign(conn, :title, "Phoenix框架动态")
    render conn, "commits.html"
  end
end
