defmodule PhoenixChina.ViewHelpers do
  use PhoenixChina.Web, :model
  use Phoenix.HTML

  alias PhoenixChina.Repo
  alias PhoenixChina.User
  alias PhoenixChina.UserFollow
  alias PhoenixChina.Post
  alias PhoenixChina.PostCollect
  alias PhoenixChina.PostPraise
  alias PhoenixChina.Comment
  alias PhoenixChina.CommentPraise

  def logged_in?(conn) do
    Guardian.Plug.authenticated?(conn)
  end

  def current_user(conn) do
    Guardian.Plug.current_resource(conn)
  end

  def admin_logged_in?(conn) do
    Guardian.Plug.authenticated?(conn, :admin)
  end

  def admin_user(conn) do
    Guardian.Plug.current_resource(conn, :admin)
  end

  def user_follow?(%User{:id => user_id}, %User{:id => to_user_id}) do
    UserFollow
    |> where(user_id: ^user_id)
    |> where(to_user_id: ^to_user_id)
    |> Repo.one
  end

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

  def from_now(datetime) do
    datetime
    |> Ecto.DateTime.to_erl
    |> Timex.from_now("zh")
  end

  def avatar(user, size \\ 40) do
    email = user.email
    |> String.trim
    |> String.downcase

    email = :crypto.hash(:md5, email)
    |> Base.encode16(case: :lower)

    "http://gravatar.eqoe.cn/avatar/#{email}?d=wavatar&s=#{size}"
  end

  def markdown(content) do
    content
    |> Earmark.to_html
    |> raw
  end
end
