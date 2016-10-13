defmodule PhoenixChina.PostPraiseController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.{User, Post, PostPraise, Notification}

  import PhoenixChina.ViewHelpers, only: [current_user: 1]
  import PhoenixChina.Ecto.Helpers, only: [increment: 2, decrement: 2]

  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixChina.GuardianErrorHandler]

  def create(conn, %{"post_id" => post_id}) do
    current_user = current_user(conn)
    post = Post |> preload([:user]) |> Repo.get!(post_id)
    params = %{:post_id => post_id, :user_id => current_user.id}
    changeset = PostPraise.changeset(%PostPraise{}, params)

    case Repo.insert(changeset) do
      {:ok, _post_collect} ->
        post |> increment(:praise_count)

        notification_html = Notification.render "post_praise.html",
          conn: conn,
          user: current_user,
          post: post

        Notification.publish(
          "post_praise",
          post.user_id,
          current_user.id,
          post.id,
          notification_html
        )

        post.user |> increment(:unread_notifications_count)

        conn
        |> put_flash(:info, "点赞成功.")
        |> redirect(to: post_path(conn, :show, post_id))
      {:error, _changeset} ->
        conn
        |> put_flash(:info, "点赞失败.")
        |> redirect(to: post_path(conn, :show, post_id))
    end
  end

  def delete(conn, %{"post_id" => post_id}) do
    current_user = current_user(conn)
    post = Repo.get!(Post, post_id)

    PostPraise
    |> Repo.get_by!(user_id: current_user.id, post_id: post_id)
    |> Repo.delete!

    post |> decrement(:praise_count)

    conn
    |> put_flash(:info, "取消点赞成功.")
    |> redirect(to: post_path(conn, :show, post_id))
  end
end
