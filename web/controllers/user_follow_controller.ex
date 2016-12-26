defmodule PhoenixChina.UserFollowController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.{User, UserFollow, Notification}
  alias Ecto.Multi

  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixChina.Guardian.ErrorHandler]

  def create(conn, %{"user_username" => username}) do
    current_user = conn.assigns[:current_user]
    to_user = Repo.get_by!(User, username: username)
    
    multi =
      Multi.new
      |> Multi.insert(:user_follow, UserFollow.changeset(%UserFollow{}, %{user_id: current_user.id, to_user_id: to_user.id}))
      |> Multi.update_all(:from_user, from(u in User, where: u.id == ^current_user.id), [inc: [followed_count: 1]])
      |> Multi.update_all(:to_user, from(u in User, where: u.id == ^to_user.id), [inc: [follower_count: 1]])
      |> Multi.run(:notification, fn _ -> 
        notification_html = Notification.render "user_follow.html", conn: conn, user: current_user
        Notification.publish "user_follow", to_user.id, current_user.id, current_user.id, notification_html
        {:ok, nil}
      end)

    case Repo.transaction(multi) do
      {:ok, _res} ->
        conn
        |> put_flash(:info, "关注成功.")
        
      {:error, _} ->
        conn
        |> put_flash(:error, "关注失败.")
    end
    |> redirect(to: user_path(conn, :show, username))
  end

  def delete(conn, %{"user_username" => username}) do
    current_user = conn.assigns[:current_user]
    to_user = Repo.get_by!(User, username: username)
    user_follow = Repo.get_by!(UserFollow, user_id: current_user.id, to_user_id: to_user.id)
    
    multi = 
      Multi.new
      |> Multi.delete(:user_follow, user_follow)
      |> Multi.update_all(:from_user, from(u in User, where: u.id == ^current_user.id), [inc: [followed_count: -1]])
      |> Multi.update_all(:to_user, from(u in User, where: u.id == ^to_user.id), [inc: [follower_count: -1]])
    
    case Repo.transaction(multi) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "取消关注成功.")
        
      {:error, _} ->
        conn
        |> put_flash(:error, "取消关注失败.")
    end
    |> redirect(to: user_path(conn, :show, username))
  end
end
