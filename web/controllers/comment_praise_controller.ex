defmodule PhoenixChina.CommentPraiseController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.{User, Post, Comment, CommentPraise, Notification}

  import PhoenixChina.ViewHelpers, only: [current_user: 1]
  import PhoenixChina.Ecto.Helpers, only: [increment: 2, decrement: 2]

  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixChina.GuardianErrorHandler]

  def create(conn, %{"comment_id" => comment_id}) do
    current_user = current_user(conn)
    comment = Comment |> preload([:user]) |> Repo.get!(comment_id)
    post = Repo.get!(Post, comment.post_id)

    params = %{:comment_id => comment_id, :user_id => current_user.id}
    changeset = CommentPraise.changeset(%CommentPraise{}, params)

    case Repo.insert(changeset) do
      {:ok, _comment_praise} ->
        comment |> increment(:praise_count)

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

        comment.user |> increment(:unread_notifications_count)

        conn
        |> put_flash(:info, "评论点赞成功.")
        |> redirect(to: post_path(conn, :show, comment.post_id))
      {:error, _changeset} ->
        conn
        |> put_flash(:info, "评论点赞失败.")
        |> redirect(to: post_path(conn, :show, comment.post_id))
    end
  end

  def delete(conn, %{"comment_id" => comment_id}) do
    current_user = current_user(conn)
    comment = Repo.get!(Comment, comment_id)

    CommentPraise
    |> Repo.get_by!(comment_id: comment_id, user_id: current_user.id)
    |> Repo.delete!

    comment |> decrement(:praise_count)

    conn
    |> put_flash(:info, "取消评论点赞成功.")
    |> redirect(to: post_path(conn, :show, comment.post_id))
  end

end
