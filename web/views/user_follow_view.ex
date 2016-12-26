defmodule PhoenixChina.UserFollowView do
  use PhoenixChina.Web, :view

  alias PhoenixChina.{Repo, UserFollow}
  import Ecto.Query

  def follow?(conn, user) do
    if conn.assigns[:authenticated?] do
      current_user = conn.assigns[:current_user]

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
