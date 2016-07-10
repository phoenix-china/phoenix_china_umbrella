defmodule PhoenixChina.LayoutView do
  use PhoenixChina.Web, :view
  use PhoenixChina.Web, :model
  use Timex

  alias PhoenixChina.Repo
  alias PhoenixChina.User
  alias PhoenixChina.UserFollow

  def user_follow?(%User{:id => user_id}, %User{:id => to_user_id}) do
    UserFollow
    |> where(user_id: ^user_id)
    |> where(to_user_id: ^to_user_id)
    |> Repo.one
  end
end
