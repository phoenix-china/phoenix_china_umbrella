defmodule PhoenixChina.CommentPraiseController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.{Comment, CommentPraise, Notification}
  alias Ecto.Multi

  import PhoenixChina.ViewHelpers, only: [current_user: 1]

  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixChina.GuardianErrorHandler]

  def create(conn, %{"comment_id" => comment_id}) do
    current_user = current_user(conn)

    multi =
      Multi.new
      |> Multi.insert(:comment_praise, CommentPraise.changeset(%CommentPraise{}, %{comment_id: comment_id, user_id: current_user.id}))
      |> Multi.update_all(:comment, from(c in Comment, where: c.id == ^comment_id), [inc: [praise_count: 1]])
      |> Multi.run(:notification, fn %{comment_praise: comment_praise} -> 
        Notification.create(conn, comment_praise)
        {:ok, nil}
      end)

    case Repo.transaction(multi) do
      {:ok, _} ->
        conn
        |> render("show.json", comment: Repo.get(Comment, comment_id), is_praise: true)

      {:error, %{comment_praise: changeset}} ->
        conn
        |> put_status(:bad_request)
        |> render("error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"comment_id" => comment_id}) do
    current_user = current_user(conn)
    comment_praise = Repo.get_by(CommentPraise, comment_id: comment_id, user_id: current_user.id)

    multi =
      Multi.new
      |> Multi.delete(:comment_praise, comment_praise)
      |> Multi.update_all(:comment, from(c in Comment, where: c.id == ^comment_id), [inc: [praise_count: -1]])
      |> Multi.run(:notification, fn _ -> 
        Notification.delete(comment_praise)
        {:ok, nil}
      end)

    case Repo.transaction(multi) do
      {:ok, _} ->
        conn
        |> render("show.json", comment: Repo.get(Comment, comment_id), is_praise: false)

      {:error, _} ->
        conn
        |> put_status(:bad_request)
        |> json(%{})
    end
  end
end
