defmodule PhoenixChina.UserFollowController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.User
  alias PhoenixChina.UserFollow
  alias PhoenixChina.Notification

  import PhoenixChina.ViewHelpers, only: [current_user: 1]
  import PhoenixChina.ModelOperator, only: [inc: 3, dec: 3]

  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixChina.GuardianHandler]
    when action in [:create, :cancel]

  def create(conn, %{"nickname" => nickname}) do
    current_user = current_user(conn)
    to_user = User |> Repo.get_by!(nickname: nickname)

    params = %{:user_id => current_user.id, :to_user_id => to_user.id}
    changeset = UserFollow.changeset(%UserFollow{}, params)

    case Repo.insert(changeset) do
      {:ok, _user_follow} ->
        User |> inc(to_user, :follower_count)
        User |> inc(current_user, :followed_count)

        notification_html = Notification.render "user_follow.html",
          conn: conn,
          user: current_user

        Notification.publish(
          "user_follow",
          to_user.id,
          current_user.id,
          current_user.id,
          notification_html
        )

        User |> inc(%{id: to_user.id}, :unread_notifications_count)

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

    User |> dec(to_user, :follower_count)
    User |> dec(current_user, :followed_count)

    conn
    |> put_flash(:info, "取消关注成功.")
    |> redirect(to: user_path(conn, :show, nickname))
  end
end
