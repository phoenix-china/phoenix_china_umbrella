defmodule PhoenixChina.PostView do
  use PhoenixChina.Web, :view
  use PhoenixChina.Web, :model

  alias PhoenixChina.Repo
  alias PhoenixChina.User
  alias PhoenixChina.Post
  alias PhoenixChina.PostCollect

  def post_collect?(%User{:id => user_id}, %Post{:id => post_id}) do
    PostCollect
    |> where(user_id: ^user_id)
    |> where(post_id: ^post_id)
    |> first
    |> Repo.one
  end
end
