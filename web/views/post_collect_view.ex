defmodule PhoenixChina.PostCollectView do
  use PhoenixChina.Web, :view

  alias PhoenixChina.{Repo, PostCollect}
  import Ecto.Query

  def collect?(conn, post) do
    if conn.assigns[:authenticated?] do
      current_user = conn.assigns[:current_user]
      collect = PostCollect
      |> where(user_id: ^current_user.id)
      |> where(post_id: ^post.id)
      |> first
      |> Repo.one

      not (collect |> is_nil)
    else
      false
    end
  end

  def render("show.json", %{is_collect: is_collect}) do
    %{
      is_collect: is_collect
    }
  end
end
