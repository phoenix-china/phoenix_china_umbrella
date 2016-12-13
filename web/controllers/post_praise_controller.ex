defmodule PhoenixChina.PostPraiseController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.{Post, PostPraise, Notification}
  alias Ecto.Multi

  import PhoenixChina.ViewHelpers, only: [current_user: 1]
  import PhoenixChina.Ecto.Helpers, only: [increment: 2, decrement: 2]

  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixChina.GuardianErrorHandler]

  def create(conn, %{"post_id" => post_id}) do
    current_user = current_user(conn)
    
    multi =
      Multi.new
      |> Multi.insert(:post_praise, PostPraise.changeset(%PostPraise{}, %{post_id: post_id, user_id: current_user.id}))
      |> Multi.update_all(:post, from(p in Post, where: p.id == ^post_id), [inc: [praise_count: 1]])
      |> Multi.run(:notification, fn %{post_praise: post_praise} -> 
        Notification.create(conn, post_praise)
        {:ok, nil}
      end)

    case Repo.transaction(multi) do
      {:ok, _} ->
        conn
        |> render("show.json", post: Repo.get(Post, post_id), is_praise: true)

      {:error, %{post_praise: changeset}} ->
        conn
        |> put_status(:bad_request)
        |> render("error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"post_id" => post_id}) do
    current_user = current_user(conn)
    post_praise =  Repo.get_by(PostPraise, user_id: current_user.id, post_id: post_id)

    multi =
      Multi.new
      |> Multi.delete(:post_praise, post_praise)
      |> Multi.update_all(:post, from(p in Post, where: p.id == ^post_id), [inc: [praise_count: -1]])
      |> Multi.run(:notification, fn _ -> 
        Notification.delete(post_praise)
        {:ok, nil}
      end)
    
    case Repo.transaction(multi) do
      {:ok, _} ->
        conn
        |> render("show.json", post: Repo.get(Post, post_id), is_praise: false)

      {:error, _} ->
        conn
        |> put_status(:bad_request)
        |> json(%{})
    end
  end
end
