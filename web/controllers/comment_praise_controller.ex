defmodule PhoenixChina.CommentPraiseController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.Comment
  alias PhoenixChina.CommentPraise

  import PhoenixChina.ViewHelpers, only: [current_user: 1]

  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixChina.GuardianHandler]
    when action in [:create, :cancel]


  def create(conn, %{"comment_id" => comment_id}) do
    current_user = current_user(conn)
    params = %{:comment_id => comment_id, :user_id => current_user.id}
    changeset = CommentPraise.changeset(%CommentPraise{}, params)
    comment = Comment |> where(id: ^comment_id) |> Repo.one!

    case Repo.insert(changeset) do
      {:ok, _comment_praise} ->
        Comment.inc_praise_count(comment_id, 1)

        conn
        |> put_flash(:info, "评论点赞成功.")
        |> redirect(to: post_path(conn, :show, comment.post_id))
      {:error, _changeset} ->
        conn
        |> put_flash(:info, "评论点赞失败.")
        |> redirect(to: post_path(conn, :show, comment.post_id))
    end
  end

  def cancel(conn, %{"comment_id" => comment_id}) do
    current_user = current_user(conn)
    comment_praise = CommentPraise
    |> where(user_id: ^current_user.id)
    |> where(comment_id: ^comment_id)
    |> Repo.one!
    Repo.delete!(comment_praise)

    Comment.inc_praise_count(comment_id, -1)
    comment = Comment |> where(id: ^comment_id) |> Repo.one!
    conn
    |> put_flash(:info, "取消评论点赞成功.")
    |> redirect(to: post_path(conn, :show, comment.post_id))
  end

end
