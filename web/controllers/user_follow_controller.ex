defmodule PhoenixChina.UserFollowController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.User
  alias PhoenixChina.UserFollow

  import PhoenixChina.ViewHelpers, only: [current_user: 1]

  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixChina.GuardianHandler]
    when action in [:create, :cancel]

  def create(conn, %{"nickname" => nickname}) do
    current_user = current_user(conn)
    to_user = User |> Repo.get_by!(nickname: nickname)

    params = %{:user_id => current_user.id, :to_user_id => to_user.id}
    changeset = UserFollow.changeset(%UserFollow{}, params)

    case Repo.insert(changeset) do
      {:ok, _user_follow} ->
        to_user |> User.inc(:follower_count)
        current_user |> User.inc(:followed_count)

        conn
        |> put_flash(:info, "关注成功.")
        |> redirect(to: user_path(conn, :show, nickname))
      {:error, _changeset} ->
        conn
        |> put_flash(:info, "关注失败.")
        |> redirect(to: user_path(conn, :show, nickname))
    end
  end

  def cancel(conn, %{"nickname" => nickname}) do
    current_user = current_user(conn)
    to_user = User |> Repo.get_by!(nickname: nickname)

    user_follow = UserFollow
    |> Repo.get_by!(user_id: current_user.id, to_user_id: to_user.id)
    
    Repo.delete!(user_follow)

    to_user |> User.dsc(:follower_count)
    current_user |> User.dsc(:followed_count)

    conn
    |> put_flash(:info, "取消关注成功.")
    |> redirect(to: user_path(conn, :show, nickname))
  end
end
