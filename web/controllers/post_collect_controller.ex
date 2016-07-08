defmodule PhoenixChina.PostCollectController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.User
  alias PhoenixChina.Post
  alias PhoenixChina.PostCollect

  import PhoenixChina.ViewHelpers, only: [current_user: 1]

  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixChina.GuardianHandler]
    when action in [:create, :cancel]

  @doc """
  收藏帖子
  """
  def create(conn, %{"post_id" => post_id}) do
    current_user = current_user(conn)
    params = %{:post_id => post_id, :user_id => current_user.id}
    changeset = PostCollect.changeset(%PostCollect{}, params)

    case Repo.insert(changeset) do
      {:ok, _post_collect} ->
        User.inc_collect_count(current_user.id, 1)
        Post.inc_collect_count(post_id, 1)

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
    post_collect = PostCollect
    |> where(user_id: ^current_user.id)
    |> where(post_id: ^post_id)
    |> Repo.one!
    Repo.delete!(post_collect)

    User.inc_collect_count(current_user.id, -1)
    Post.inc_collect_count(post_id, -1)
    conn
    |> put_flash(:info, "取消收藏成功.")
    |> redirect(to: post_path(conn, :show, post_id))
  end
end
