defmodule PhoenixChina.CommentPraiseView do
  use PhoenixChina.Web, :view

  alias PhoenixChina.{Repo, ViewHelpers, CommentPraise}
  import Ecto.Query

  def praise?(conn, comment) do
    if ViewHelpers.logged_in?(conn) do
      current_user = ViewHelpers.current_user(conn)
      praise = CommentPraise
      |> where(user_id: ^current_user.id)
      |> where(comment_id: ^comment.id)
      |> first
      |> Repo.one

      not (praise |> is_nil)
    else
      false
    end
  end

  def praise_count(comment) do
    case comment.praise_count > 0 do
      true -> to_string(comment.praise_count) <> "个赞"
      false -> "赞"
    end
  end

  def render("show.json", %{comment: comment, is_praise: is_praise}) do
    %{
      is_praise: is_praise,
      data: render_one(comment, PhoenixChina.CommentView, "comment.json")
    }
  end
end
