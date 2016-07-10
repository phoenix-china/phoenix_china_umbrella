defmodule PhoenixChina.CommentView do
  use PhoenixChina.Web, :view
  use PhoenixChina.Web, :model

  alias PhoenixChina.Repo
  alias PhoenixChina.User
  alias PhoenixChina.Comment
  alias PhoenixChina.CommentPraise

  def comment_praise?(%User{:id => user_id}, %Comment{:id => comment_id}) do
    CommentPraise
    |> where(user_id: ^user_id)
    |> where(comment_id: ^comment_id)
    |> first
    |> Repo.one
  end
end
