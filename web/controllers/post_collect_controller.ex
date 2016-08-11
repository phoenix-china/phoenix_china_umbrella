defmodule PhoenixChina.PostCollectController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.User
  alias PhoenixChina.Post
  alias PhoenixChina.PostCollect
  alias PhoenixChina.Notification

  import PhoenixChina.ViewHelpers, only: [current_user: 1]
  import PhoenixChina.ModelOperator, only: [inc: 3, dec: 3]

  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixChina.GuardianHandler]
    when action in [:create, :cancel]

  @doc """
  收藏帖子
  """
  def create(conn, %{"post_id" => post_id}) do
    current_user = current_user(conn)
    post = Repo.get!(Post, post_id)
    params = %{:post_id => post_id, :user_id => current_user.id}
    changeset = PostCollect.changeset(%PostCollect{}, params)

    case Repo.insert(changeset) do
      {:ok, _post_collect} ->
        User |> inc(current_user, :collect_count)
        Post |> inc(post, :collect_count)

        notification_html = Notification.render "post_collect.html",
          conn: conn,
          user: current_user,
          post: post

        Notification.publish(
          "post_collect",
          post.user_id,
          current_user.id,
          post.id,
          notification_html
        )

        conn
        |> put_flash(:info, "收藏成功.")
        |> redirect(to: post_path(conn, :show, post_id))
      {:error, _changeset} ->
        conn
        |> put_flash(:info, "收藏失败.")
        |> redirect(to: post_path(conn, :show, post_id))
    end
  end

  @doc """
  取消收藏帖子
  """
  def cancel(conn, %{"post_id" => post_id}) do
    current_user = current_user(conn)
    post = Repo.get!(Post, post_id)

    post_collect = PostCollect
    |> Repo.get_by!(user_id: current_user.id, post_id: post_id)

    Repo.delete!(post_collect)

    User |> dec(current_user, :collect_count)
    Post |> dec(post, :collect_count)

    conn
    |> put_flash(:info, "取消收藏成功.")
    |> redirect(to: post_path(conn, :show, post_id))
  end
end
