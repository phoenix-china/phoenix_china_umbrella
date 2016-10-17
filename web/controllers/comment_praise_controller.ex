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
        comment = increment(comment, :praise_count)

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
        |> render("show.json", comment: comment, is_praise: true)
      {:error, changeset} ->
        conn
        |> put_status(:bad_request)
        |> render("error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"comment_id" => comment_id}) do
    current_user = current_user(conn)
    comment = Repo.get!(Comment, comment_id)

    CommentPraise
    |> Repo.get_by!(comment_id: comment_id, user_id: current_user.id)
    |> Repo.delete!

    comment = decrement(comment, :praise_count)

    conn
    |> render("show.json", comment: comment, is_praise: false)
  end

end
