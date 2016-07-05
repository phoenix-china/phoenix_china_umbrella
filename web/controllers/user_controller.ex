defmodule PhoenixChina.UserController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.User
  alias PhoenixChina.Post
  alias PhoenixChina.Comment
  alias PhoenixChina.LayoutView

  import PhoenixChina.Mailer, only: [send_confirmation_email: 2, send_reset_password_email: 2]
  import PhoenixChina.ViewHelpers, only: [current_user: 1]

  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixChina.GuardianHandler]
    when action in [:profile, :account]

  plug PhoenixChina.GuardianPlug
  plug :put_layout, "user.html"

  plug :load_data when action in [:show, :profile, :account, :account_update, :comments]
  defp load_data(conn, _) do
    user = case conn.params do
      %{"nickname" => nickname} ->
        (from User, where: [nickname: ^nickname])
        |> first
        |> Repo.one!
      _ ->
        current_user(conn)
    end

    post_count = Post
    |> where([p], p.user_id == ^user.id)
    |> select([p], count(p.id))
    |> Repo.one

    comment_count = Comment
    |> where([c], c.user_id == ^user.id)
    |> select([c], count(c.id))
    |> Repo.one

    conn
    |> assign(:user, user)
    |> assign(:post_count, post_count)
    |> assign(:comment_count, comment_count)
  end

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
      {:ok, user} ->
        send_confirmation_email(conn, user)
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

    page = (from Post, where: [user_id: ^user.id], order_by: [desc: :inserted_at], preload: [:user])
    |> Repo.paginate(%{"page" => page})

    render conn, "show.html",
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
    render conn, "profile.html",
      current_page: :profile
  end

  def account(conn, _params) do
    user = current_user(conn)
    changeset = User.changeset(:account, user)

    render conn, "account.html",
      current_page: :account,
      changeset: changeset
  end

  def account_update(conn, %{"user" => user_params}) do
    user = current_user(conn)
    changeset = User.changeset(:account, user, user_params)
    |> User.validate_password(:old_password)
    |> User.validate_equal_to(:password_confirm, :password)
    |> User.put_password_hash

    case Repo.update(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "密码修改成功！")
        |> redirect(to: user_path(conn, :account))
      {:error, changeset} ->
        render conn, "account.html",
          current_page: :account,
          changeset: changeset
    end
  end

  @doc """
  用户评论列表
  """
  def comments(conn, %{"nickname" => nickname, "page" => page}) do
    user = (from User, where: [nickname: ^nickname])
    |> first
    |> Repo.one!

    page = (from Comment, where: [user_id: ^user.id], order_by: [desc: :inserted_at], preload: [:user, :post])
    |> Repo.paginate(%{"page" => page})

    render conn, "comments.html",
      page: page,
      current_page: nil
  end

  def comments(conn, %{"nickname" => nickname}) do
    comments(conn, %{"nickname" => nickname, "page" => "1"})
  end

  @doc """
  用户请求通过邮件地址重置密码
  """
  def password_forget(conn, _params) do
    changeset = User.changeset(:password_forget, %User{})
    render conn, "password_forget.html",
      layout: {LayoutView, "app.html"},
      changeset: changeset
  end

  def post_password_forget(conn, %{"user" => user_params}) do
    changeset = User.changeset(:password_forget, %User{}, user_params)
    |> validate_email

    case changeset.valid? do
      true ->
        send_reset_password_email(conn, changeset.changes.user)
        conn
        |> put_flash(:info, "稍后，您将收到重置密码的电子邮件。")
        |> redirect(to: user_path(conn, :password_forget))
      false ->
        changeset = %{changeset | action: :password_forget}
        render conn, "password_forget.html",
          layout: {LayoutView, "app.html"},
          changeset: changeset
    end
  end

  defp validate_email(changeset) do
    user = (from User, where: [email: ^changeset.changes.email]) |> first |> Repo.one
    case !changeset.errors[:email] && !user do
      true ->
        changeset
        |> Ecto.Changeset.add_error(:email, "邮箱未注册")
      false ->
        changeset
        |> Ecto.Changeset.put_change(:user, user)
    end
  end

  @doc """
  用户重置密码
  """
  def password_reset(conn, %{"password_reset_token" => token}) do
      text conn, "password reset"
  end
end
