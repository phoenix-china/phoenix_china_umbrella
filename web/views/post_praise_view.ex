defmodule PhoenixChina.PostPraiseView do
  use PhoenixChina.Web, :view

  alias PhoenixChina.{Repo, ViewHelpers, PostPraise}
  import Ecto.Query

  def praise?(conn, post) do
    if ViewHelpers.logged_in?(conn) do
      current_user = ViewHelpers.current_user(conn)
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
end
