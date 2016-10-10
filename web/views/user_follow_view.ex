defmodule PhoenixChina.UserFollowView do
  use PhoenixChina.Web, :view

  alias PhoenixChina.{Repo, ViewHelpers, UserFollow}
  import Ecto.Query

  def follow?(conn, user) do
    if ViewHelpers.logged_in?(conn) do
      current_user = ViewHelpers.current_user(conn)

      follow = UserFollow
      |> where(user_id: ^current_user.id)
      |> where(to_user_id: ^user.id)
      |> first
      |> Repo.one

      not (follow |> is_nil)
    else
      false
    end
  end
end
