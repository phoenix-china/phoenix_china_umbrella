defmodule PhoenixChina.PostCollectView do
  use PhoenixChina.Web, :view

  alias PhoenixChina.{Repo, ViewHelpers, PostCollect}
  import Ecto.Query

  def collect?(conn, post) do
    if ViewHelpers.logged_in?(conn) do
      current_user = ViewHelpers.current_user(conn)
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
end
