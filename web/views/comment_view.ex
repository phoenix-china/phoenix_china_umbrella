defmodule PhoenixChina.CommentView do
  use PhoenixChina.Web, :view
  use PhoenixChina.Web, :model

  alias PhoenixChina.Repo
  alias PhoenixChina.User
  alias PhoenixChina.Post
  alias PhoenixChina.PostCollect
  alias PhoenixChina.PostPraise
  alias PhoenixChina.Comment
  alias PhoenixChina.CommentPraise

  def post_collect?(%User{:id => user_id}, %Post{:id => post_id}) do
    PostCollect
    |> where(user_id: ^user_id)
    |> where(post_id: ^post_id)
    |> first
    |> Repo.one
  end

  def post_praise?(%User{:id => user_id}, %Post{:id => post_id}) do
    PostPraise
    |> where(user_id: ^user_id)
    |> where(post_id: ^post_id)
    |> first
    |> Repo.one
  end

  def comment_praise?(%User{:id => user_id}, %Comment{:id => comment_id}) do
    CommentPraise
    |> where(user_id: ^user_id)
    |> where(comment_id: ^comment_id)
    |> first
    |> Repo.one
  end
end
