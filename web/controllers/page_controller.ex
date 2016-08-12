defmodule PhoenixChina.PageController do
  use PhoenixChina.Web, :controller
  alias PhoenixChina.Post

  plug PhoenixChina.GuardianPlug

  def index(conn, %{"page" => page_num}) do
    page = ConCache.get_or_store(:phoenix_china, "page_index:page:#{page_num}", fn() ->
      Post
      |> order_by(desc: :is_top, desc: :latest_comment_inserted_at)
      |> preload([:user, :latest_comment, latest_comment: :user])
      |> Repo.paginate(%{"page" => page_num})
    end)

    post_list_html = ConCache.get_or_store(:phoenix_china, "page_index:html:#{page_num}", fn() ->
      Phoenix.View.render_to_string(PhoenixChina.PostView, "entries.html", %{conn: conn, page: page})
    end)

    render conn, "index.html",
      post_list_html: post_list_html,
      page: page
  end

  def index(conn, %{}) do
    index(conn, %{"page" => "1"})
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
