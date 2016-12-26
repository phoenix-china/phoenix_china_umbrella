defmodule PhoenixChina.PostCollectController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.{User, Post, PostCollect, Notification}
  alias Ecto.Multi

  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixChina.Guardian.ErrorHandler]

  @doc """
  收藏帖子
  """
  def create(conn, %{"post_id" => post_id}) do
    current_user = conn.assigns[:current_user]

    multi =
      Multi.new
      |> Multi.insert(:post_collect, PostCollect.changeset(%PostCollect{}, %{post_id: post_id, user_id: current_user.id}))
      |> Multi.update_all(:post, from(p in Post, where: p.id == ^post_id), [inc: [collect_count: 1]])
      |> Multi.update_all(:user, from(u in User, where: u.id == ^current_user.id), [inc: [collect_count: 1]])
      |> Multi.run(:notification, fn %{post_collect: post_collect} -> 
        Notification.create(conn, post_collect)
        {:ok, nil}
      end)

    case Repo.transaction(multi) do
      {:ok, _} ->
        conn
        |> render("show.json", is_collect: true)

      {:error, %{post_praise: changeset}} ->
        conn
        |> put_status(:bad_request)
        |> render("error.json", changeset: changeset)
    end
  end

  @doc """
  取消收藏帖子
  """
  def delete(conn, %{"post_id" => post_id}) do
    current_user = conn.assigns[:current_user]
    post_collect = Repo.get_by(PostCollect, user_id: current_user.id, post_id: post_id)

    multi =
      Multi.new
      |> Multi.delete(:post_collect, post_collect)
      |> Multi.update_all(:post, from(p in Post, where: p.id == ^post_id), [inc: [collect_count: -1]])
      |> Multi.update_all(:user, from(u in User, where: u.id == ^current_user.id), [inc: [collect_count: -1]])
      |> Multi.run(:notification, fn _ -> 
        Notification.delete(post_collect)
        {:ok, nil}
      end)

    case Repo.transaction(multi) do
      {:ok, _} ->
        conn
        |> render("show.json", is_collect: false)

      {:error, _} ->
        conn
        |> put_status(:bad_request)
        |> json(%{})
    end
  end
end
