defmodule PhoenixChina.UserController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.User
  alias PhoenixChina.Post
  alias PhoenixChina.Comment
  alias PhoenixChina.PostCollect
  alias PhoenixChina.UserFollow
  alias PhoenixChina.LayoutView

  import PhoenixChina.Mailer, only: [send_confirmation_email: 2, send_reset_password_email: 2]
  import PhoenixChina.ViewHelpers, only: [current_user: 1]

  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixChina.GuardianHandler]
    when action in [:profile, :account]

  plug PhoenixChina.GuardianPlug
  plug :put_layout, "user.html"

  plug :load_data when action in [:show, :profile, :put_profile, :account,
                                  :put_account, :comments, :collects, :follower,
                                  :followed]
  defp load_data(conn, _) do
    user = case conn.params do
      %{"nickname" => nickname} ->
        User |> Repo.get_by!(nickname: nickname)
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

  def create(conn, %{"user" => user_params, "luotest_response" => luotest_response}) do
    changeset = User.changeset(:signup, %User{}, user_params |> Dict.put_new("luotest_response", luotest_response))

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
    user = User |> Repo.get_by!(nickname: nickname)

    page = Post
    |> where(user_id: ^user.id)
    |> order_by(desc: :inserted_at)
    |> preload([:user, :latest_comment, latest_comment: :user])
    |> Repo.paginate(%{"page" => page})

    render conn, "show.html",
      page: page,
      current_page: nil
  end

  def show(conn, %{"nickname" => nickname}) do
    show(conn, %{"nickname" => nickname, "page" => "1"})
  end

  def profile(conn, _params) do
    user = current_user(conn)
    changeset = User.changeset(:profile, user)

    render conn, "profile.html",
      current_page: :profile,
      changeset: changeset
  end

  def put_profile(conn, %{"user" => user_params}) do
    user = current_user(conn)
    changeset = User.changeset(:profile, user, user_params)

    case Repo.update(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "个人信息编辑成功！")
        |> redirect(to: user_path(conn, :profile))
      {:error, changeset} ->
        render conn, "profile.html",
          current_page: :profile,
          changeset: changeset
    end
  end

  def account(conn, _params) do
    user = current_user(conn)
    changeset = User.changeset(:account, user)

    render conn, "account.html",
      current_page: :account,
      changeset: changeset
  end

  def put_account(conn, %{"user" => user_params}) do
    user = current_user(conn)
    changeset = User.changeset(:account, user, user_params)

    case Repo.update(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "密码修改成功！")
        |> redirect(to: user_path(conn, :account))
      {:error, changeset} ->
        changeset = %{changeset | action: :account}
        render conn, "account.html",
          current_page: :account,
          changeset: changeset
    end
  end

  @doc """
  用户评论列表
  """
  def comments(conn, %{"nickname" => nickname, "page" => page}) do
    user = User |> Repo.get_by!(nickname: nickname)

    page = Comment
    |> where(user_id: ^user.id)
    |> order_by(desc: :inserted_at)
    |> preload([:user, :post, post: :user])
    |> Repo.paginate(%{"page" => page})

    render conn, "comments.html",
      page: page,
      current_page: nil
  end

  def comments(conn, %{"nickname" => nickname}) do
    comments(conn, %{"nickname" => nickname, "page" => "1"})
  end

  def collects(conn, %{"nickname" => nickname, "page" => page}) do
    user = User |> Repo.get_by!(nickname: nickname)

    page = PostCollect
    |> preload([:post, post: [:user, :latest_comment, latest_comment: :user]])
    |> where(user_id: ^user.id)
    |> order_by(desc: :inserted_at)
    |> Repo.paginate(%{"page" => page})

    render conn, "collects.html",
      page: page,
      current_page: nil
  end

  def collects(conn, %{"nickname" => nickname}) do
    collects(conn, %{"nickname" => nickname, "page" => "1"})
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

    case changeset.valid? do
      true ->
        user = User |> Repo.get_by!(email: changeset.changes.email)
        send_reset_password_email(conn, user)
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

  @doc """
  用户重置密码
  """
  def password_reset(conn, %{"password_reset_token" => token}) do
    changeset = User.changeset(:password_reset, %User{}, %{"token" => token})

    conn = case changeset.errors[:token] do
      {msg, _} ->
        conn
        |> put_flash(:info, msg)
        |> redirect(to: user_path(conn, :password_forget))
      _ ->
        conn
        |> put_flash(:info, "您正在重置账号为 #{changeset.changes.user.email} 的密码")
    end

    changeset = User.changeset(:password_reset, changeset.changes.user, %{"token" => token})

    render conn, "password_reset.html",
      layout: {LayoutView, "app.html"},
      changeset: changeset
  end

  def password_reset(conn, %{}) do
    conn
    |> put_flash(:info, "非法访问")
    |> redirect(to: page_path(conn, :index))
  end

  @doc """
  用户重置密码
  """
  def put_password_reset(conn, %{"user" => user_params}) do
    changeset = User.changeset(:password_reset, %User{}, user_params)
    changeset = User.changeset(:password_reset, changeset.changes.user, user_params)

    case Repo.update(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "密码重置成功，请登录！")
        |> redirect(to: session_path(conn, :new))
      {:error, changeset} ->
        render conn, "password_reset.html",
          layout: {LayoutView, "app.html"},
          changeset: changeset
    end
  end

  @doc """
  关注者
  """
  def follower(conn, %{"nickname" => nickname, "page" => page}) do
    user = User |> Repo.get_by!(nickname: nickname)

    page = UserFollow
    |> where(to_user_id: ^user.id)
    |> order_by(desc: :inserted_at)
    |> preload(:user)
    |> Repo.paginate(%{"page" => page})

    render conn, "follower.html",
      page: page,
      current_page: nil
  end

  def follower(conn, %{"nickname" => nickname}) do
    follower(conn, %{"nickname" => nickname, "page" => "1"})
  end

  @doc """
  正在关注
  """
  def followed(conn, %{"nickname" => nickname, "page" => page}) do
    user = User |> Repo.get_by!(nickname: nickname)

    page = UserFollow
    |> where(user_id: ^user.id)
    |> order_by(desc: :inserted_at)
    |> preload(:to_user)
    |> Repo.paginate(%{"page" => page})

    render conn, "followed.html",
      page: page,
      current_page: nil
  end

  def followed(conn, %{"nickname" => nickname}) do
    followed(conn, %{"nickname" => nickname, "page" => "1"})
  end

  def avatar(conn, %{"nickname" => nickname}) do
    content = ConCache.get_or_store(:phoenix_china, "avatar:#{nickname}", fn() ->
      user = User |> Repo.get_by!(nickname: nickname)
      url = user |> generate_avatar_url
      response = HTTPotion.get url
      response.body
    end)

    text conn, content
  end

  defp generate_avatar_url(user, size \\ 40) do
    email = user.email
    |> String.trim
    |> String.downcase

    email = :crypto.hash(:md5, email)
    |> Base.encode16(case: :lower)

    "http://gravatar.eqoe.cn/avatar/#{email}?d=wavatar&s=#{size}"
  end
end
