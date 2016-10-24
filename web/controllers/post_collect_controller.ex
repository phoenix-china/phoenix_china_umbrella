defmodule PhoenixChina.PostCollectController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.{Post, PostCollect, Notification}

  import PhoenixChina.ViewHelpers, only: [current_user: 1]
  import PhoenixChina.Ecto.Helpers, only: [increment: 2, decrement: 2]

  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixChina.GuardianErrorHandler]

  @doc """
  收藏帖子
  """
  def create(conn, %{"post_id" => post_id}) do
    current_user = current_user(conn)
    post = Post |> preload([:user]) |> Repo.get!(post_id)
    params = %{:post_id => post_id, :user_id => current_user.id}
    changeset = PostCollect.changeset(%PostCollect{}, params)

    case Repo.insert(changeset) do
      {:ok, post_collect} ->
        current_user |> increment(:collect_count)
        post |> increment(:collect_count)

        Notification.create(conn, post_collect)

        conn
        |> render("show.json", is_collect: true)
      {:error, _changeset} ->
        conn
        |> put_status(:bad_request)
        |> render("error.json", changeset: changeset)
    end
  end

  @doc """
  取消收藏帖子
  """
  def delete(conn, %{"post_id" => post_id}) do
    current_user = current_user(conn)
    post = Post |> preload([:user]) |> Repo.get!(post_id)

    post_collect = PostCollect |> Repo.get_by!(user_id: current_user.id, post_id: post_id)

    Notification.delete(post_collect)

    post_collect |> Repo.delete!

    current_user |> decrement(:collect_count)
    post |> decrement(:collect_count)

    conn
    |> render("show.json", is_collect: false)
  end
end
