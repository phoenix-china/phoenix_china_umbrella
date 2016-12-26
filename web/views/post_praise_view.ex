defmodule PhoenixChina.PostPraiseView do
  use PhoenixChina.Web, :view

  alias PhoenixChina.{Repo, PostPraise}
  import Ecto.Query

  def praise?(conn, post) do
    if conn.assigns[:authenticated?] do
      current_user = conn.assigns[:current_user]
      praise = PostPraise
      |> where(user_id: ^current_user.id)
      |> where(post_id: ^post.id)
      |> first
      |> Repo.one

      not (praise |> is_nil)
    else
      false
    end
  end

  def praise_count(post) do
    case post.praise_count > 0 do
      true -> to_string(post.praise_count) <> "个赞"
      false -> "赞"
    end
  end

  def render("show.json", %{post: post, is_praise: is_praise}) do
    %{
      is_praise: is_praise,
      data: render_one(post, PhoenixChina.PostView, "post.json")
    }
  end
end
