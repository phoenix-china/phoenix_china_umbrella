defmodule PhoenixChina.CommentPraiseController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.Post
  alias PhoenixChina.Comment
  alias PhoenixChina.CommentPraise
  alias PhoenixChina.Notification

  import PhoenixChina.ViewHelpers, only: [current_user: 1]
  import PhoenixChina.ModelOperator, only: [inc: 3, dec: 3]

  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixChina.GuardianHandler]
    when action in [:create, :cancel]


  def create(conn, %{"comment_id" => comment_id}) do
    current_user = current_user(conn)
    comment = Repo.get!(Comment, comment_id)
    post = Repo.get!(Post, comment.post_id)

    params = %{:comment_id => comment_id, :user_id => current_user.id}
    changeset = CommentPraise.changeset(%CommentPraise{}, params)

    case Repo.insert(changeset) do
      {:ok, _comment_praise} ->
        Comment |> inc(comment, :praise_count)

        notification_html = Notification.render "comment_praise.html",
          conn: conn,
          user: current_user,
          post: post,
          comment: comment

        Notification.publish(
          "comment_praise",
          comment.user_id,
          current_user.id,
          comment.id,
          notification_html
        )

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
    comment = Repo.get!(Comment, comment_id)

    comment_praise = CommentPraise
    |> where(user_id: ^current_user.id)
    |> where(comment_id: ^comment_id)
    |> Repo.one!
    Repo.delete!(comment_praise)

    Comment |> dec(comment, :praise_count)

    conn
    |> put_flash(:info, "取消评论点赞成功.")
    |> redirect(to: post_path(conn, :show, comment.post_id))
  end

end
