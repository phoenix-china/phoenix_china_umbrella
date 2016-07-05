defmodule PhoenixChina.UserController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.User
  alias PhoenixChina.Post
  alias PhoenixChina.Comment
  alias PhoenixChina.LayoutView

  import PhoenixChina.ViewHelpers, only: [current_user: 1]

  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixChina.GuardianHandler]
    when action in [:profile, :account]

  plug PhoenixChina.GuardianPlug
  plug :put_layout, "user.html"

  def new(conn, _params) do
    changeset = User.changeset(:signup, %User{})
    render conn, "new.html",
      layout: {LayoutView, "app.html"},
      changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(:signup, %User{}, user_params)
    |> User.put_password_hash

    case Repo.insert(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "注册成功了！.")
        |> redirect(to: session_path(conn, :new))
      {:error, changeset} ->
        render conn, "new.html",
          layout: {LayoutView, "app.html"},
          changeset: changeset
    end
  end

  def show(conn, %{"nickname" => nickname, "page" => page}) do
    user = (from User, where: [nickname: ^nickname])
    |> first
    |> Repo.one!

    post_count = Post
    |> where([p], p.user_id == ^user.id)
    |> select([p], count(p.id))
    |> Repo.one

    comment_count = Comment
    |> where([c], c.user_id == ^user.id)
    |> select([c], count(c.id))
    |> Repo.one

    page = (from Post, where: [user_id: ^user.id], order_by: [desc: :inserted_at], preload: [:user])
    |> Repo.paginate(%{"page" => page})

    render conn, "show.html",
      user: user,
      post_count: post_count,
      comment_count: comment_count,
      posts: page.entries,
      page: page,
      current_page: nil
  end

  def show(conn, %{"nickname" => nickname}) do
    show(conn, %{"nickname" => nickname, "page" => "1"})
  end

  def edit(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(:edit, user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def profile(conn, _params) do
    user = current_user(conn)

    post_count = Post
    |> where([p], p.user_id == ^user.id)
    |> select([p], count(p.id))
    |> Repo.one

    comment_count = Comment
    |> where([c], c.user_id == ^user.id)
    |> select([c], count(c.id))
    |> Repo.one

    render conn, "profile.html",
      current_page: :profile,
      user: user,
      post_count: post_count,
      comment_count: comment_count
  end

  def account(conn, _params) do
    user = current_user(conn)

    post_count = Post
    |> where([p], p.user_id == ^user.id)
    |> select([p], count(p.id))
    |> Repo.one

    comment_count = Comment
    |> where([c], c.user_id == ^user.id)
    |> select([c], count(c.id))
    |> Repo.one

    changeset = User.changeset(:account, user)

    render conn, "account.html",
      current_page: :account,
      user: user,
      post_count: post_count,
      comment_count: comment_count,
      changeset: changeset
  end

  def account_update(conn, %{"user" => user_params}) do
    user = current_user(conn)
    changeset = User.changeset(:account, user, user_params)
    |> User.validate_password(:old_password)
    |> User.validate_equal_to(:password_confirm, :password)
    |> User.put_password_hash

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "密码修改成功！")
        |> redirect(to: user_path(conn, :account))
      {:error, changeset} ->
        post_count = Post
        |> where([p], p.user_id == ^user.id)
        |> select([p], count(p.id))
        |> Repo.one

        comment_count = Comment
        |> where([c], c.user_id == ^user.id)
        |> select([c], count(c.id))
        |> Repo.one

        render conn, "account.html",
          current_page: :account,
          user: user,
          post_count: post_count,
          comment_count: comment_count,
          changeset: changeset
    end
  end

end
