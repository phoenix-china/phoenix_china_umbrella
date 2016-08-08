defmodule PhoenixChina.PostPraiseController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.Post
  alias PhoenixChina.PostPraise

  import PhoenixChina.ViewHelpers, only: [current_user: 1]
  import PhoenixChina.ModelOperator, only: [inc: 3, dec: 3]

  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixChina.GuardianHandler]
    when action in [:create, :cancel]

  def create(conn, %{"post_id" => post_id}) do
    current_user = current_user(conn)
    post = Repo.get!(Post, post_id)
    params = %{:post_id => post_id, :user_id => current_user.id}
    changeset = PostPraise.changeset(%PostPraise{}, params)

    case Repo.insert(changeset) do
      {:ok, _post_collect} ->
        Post |> inc(post, :praise_count)

        conn
        |> put_flash(:info, "点赞成功.")
        |> redirect(to: post_path(conn, :show, post_id))
      {:error, _changeset} ->
        conn
        |> put_flash(:info, "点赞失败.")
        |> redirect(to: post_path(conn, :show, post_id))
    end
  end

  def cancel(conn, %{"post_id" => post_id}) do
    current_user = current_user(conn)
    post = Repo.get!(Post, post_id)

    post_praise = PostPraise
    |> Repo.get_by!(user_id: current_user.id, post_id: post_id)

    Repo.delete!(post_praise)

    Post |> dec(post, :praise_count)

    conn
    |> put_flash(:info, "取消点赞成功.")
    |> redirect(to: post_path(conn, :show, post_id))
  end
end
