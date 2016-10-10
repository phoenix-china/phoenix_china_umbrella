defmodule PhoenixChina.UserController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.{User, Post, Comment, PostCollect, UserFollow, LayoutView}

  import PhoenixChina.Mailer, only: [send_confirmation_email: 2, send_reset_password_email: 2]
  import PhoenixChina.ViewHelpers, only: [current_user: 1, logged_in?: 1]


  defp who(conn, user) do
    cond do
      logged_in?(conn) && current_user(conn).id == user.id -> "我"
      true -> user.nickname
    end
  end

  def new(conn, _params) do
    changeset = User.changeset(:signup, %User{})
    conn = assign(conn, :title, "用户注册")
    render conn, "new.html",
      changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(:signup, %User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        send_confirmation_email(conn, user)
        conn
        |> put_flash(:info, "注册成功了！.")
        |> redirect(to: session_path(conn, :new))
      {:error, changeset} ->
        render conn, "new.html",
          changeset: changeset
    end
  end

  @doc """
  主页
  """
  def show(conn, %{"username" => username, "tab" => "index"}) do
    user = Repo.get_by(User, %{username: username})

    conn
    |> assign(:title, user.username <> " 的主页")
    |> assign(:user, user)
    |> assign(:current_tab, "index")
    |> render("show-index.html")
  end

  @doc """
  帖子
  """
  def show(conn, %{"username" => username, "tab" => "post"} = params) do
    user = Repo.get_by(User, %{username: username})

    pagination = Post
    |> where(user_id: ^user.id)
    |> order_by([:inserted_at])
    |> preload([:label, :latest_comment, latest_comment: :user])
    |> Repo.paginate(params)

    conn
    |> assign(:title, user.username <> " 的帖子")
    |> assign(:user, user)
    |> assign(:current_tab, "post")
    |> assign(:pagination, pagination)
    |> render("show-post.html")
  end

  @doc """
  回复
  """
  def show(conn, %{"username" => username, "tab" => "comment"} = params) do
    user = Repo.get_by(User, %{username: username})

    pagination = Comment
    |> where(user_id: ^user.id)
    |> order_by([:inserted_at])
    |> preload([:post])
    |> Repo.paginate(params)

    conn
    |> assign(:title, user.username <> " 的回复")
    |> assign(:user, user)
    |> assign(:current_tab, "comment")
    |> assign(:pagination, pagination)
    |> render("show-comment.html")
  end

  @doc """
  收藏
  """
  def show(conn, %{"username" => username, "tab" => "collect"} = params) do
    user = Repo.get_by(User, %{username: username})

    pagination = Post
    |> join(:inner, [p], c in PostCollect, c.post_id == p.id and c.user_id == ^user.id)
    |> order_by([:inserted_at])
    |> preload([:user, :label, :latest_comment, latest_comment: :user])
    |> Repo.paginate(params)

    conn
    |> assign(:title, user.username <> " 的收藏")
    |> assign(:user, user)
    |> assign(:current_tab, "collect")
    |> assign(:pagination, pagination)
    |> render("show-collect.html")
  end

  @doc """
  关注者
  """
  def show(conn, %{"username" => username, "tab" => "followers"} = params) do
    user = Repo.get_by(User, %{username: username})

    pagination = User
    |> join(:inner, [u], f in UserFollow, f.user_id == u.id and f.to_user_id == ^user.id)
    |> order_by([:inserted_at])
    |> Repo.paginate(params)

    conn
    |> assign(:title, user.username <> " 的关注者")
    |> assign(:user, user)
    |> assign(:current_tab, "followers")
    |> assign(:pagination, pagination)
    |> render("show-followers.html")
  end

  @doc """
  正在关注
  """
  def show(conn, %{"username" => username, "tab" => "following"} = params) do
    user = Repo.get_by(User, %{username: username})

    pagination = User
    |> join(:inner, [u], f in UserFollow, f.user_id == ^user.id and f.to_user_id == u.id)
    |> order_by([:inserted_at])
    |> Repo.paginate(params)

    conn
    |> assign(:title, user.username <> " 的正在关注")
    |> assign(:user, user)
    |> assign(:current_tab, "following")
    |> assign(:pagination, pagination)
    |> render("show-following.html")
  end

  def show(conn, %{"username" => username}) do
    show(conn, %{"username" => username, "tab" => "index"})
  end


  # def show(conn, %{"username" => username, "page" => page}) do
  #   user = User |> Repo.get_by!(username: username)
  #
  #   conn = assign(conn, :title, "#{who(conn, user)}的主页")
  #
  #   page = Post
  #   |> where(user_id: ^user.id)
  #   |> order_by(desc: :inserted_at)
  #   |> preload([:label, :user, :latest_comment, latest_comment: :user])
  #   |> Repo.paginate(%{"page" => page})
  #
  #   render conn, "show.html",
  #     page: page,
  #     current_page: nil
  # end
  #
  # def show(conn, %{"username" => username}) do
  #   show(conn, %{"username" => username, "page" => "1"})
  # end

  def profile(conn, _params) do
    user = current_user(conn)
    changeset = User.changeset(:profile, user)

    conn = assign(conn, :title, "编辑个人信息")

    render conn, "profile.html",
      current_page: :profile,
      changeset: changeset
  end

  def put_profile(conn, %{"user" => user_params}) do
    user = current_user(conn)

    #upload to qiniu
    # file = user_params["avatar"]
    # unless is_nil(file) do
    #   [filename, url] = PhoenixChina.Qiniu.filename_and_url(file)
    #   Task.async(fn -> PhoenixChina.Qiniu.upload(file, filename) end)
    #   user_params = %{user_params | "avatar" => url}
    # end

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

    conn = assign(conn, :title, "修改密码")

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
  def comments(conn, %{"username" => username, "page" => page}) do
    user = User |> Repo.get_by!(username: username)

    conn = assign(conn, :title, "#{who(conn, user)}的评论列表")

    page = Comment
    |> where(user_id: ^user.id)
    |> order_by(desc: :inserted_at)
    |> preload([:user, :post, post: :user])
    |> Repo.paginate(%{"page" => page})

    render conn, "comments.html",
      page: page,
      current_page: nil
  end

  def comments(conn, %{"username" => username}) do
    comments(conn, %{"username" => username, "page" => "1"})
  end

  def collects(conn, %{"username" => username, "page" => page}) do
    user = User |> Repo.get_by!(username: username)

    conn = assign(conn, :title, "#{who(conn, user)}的收藏")

    page = PostCollect
    |> preload([:post, post: [:label, :user, :latest_comment, latest_comment: :user]])
    |> where(user_id: ^user.id)
    |> order_by(desc: :inserted_at)
    |> Repo.paginate(%{"page" => page})

    render conn, "collects.html",
      page: page,
      current_page: nil
  end

  def collects(conn, %{"username" => username}) do
    collects(conn, %{"username" => username, "page" => "1"})
  end

  @doc """
  用户请求通过邮件地址重置密码
  """
  def password_forget(conn, _params) do
    changeset = User.changeset(:password_forget, %User{})

    conn = assign(conn, :title, "邮箱找回密码")

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

    conn = assign(conn, :title, "重置密码")

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
  def follower(conn, %{"username" => username, "page" => page}) do
    user = User |> Repo.get_by!(username: username)

    conn = assign(conn, :title, "#{who(conn, user)}的关注者")

    page = UserFollow
    |> where(to_user_id: ^user.id)
    |> order_by(desc: :inserted_at)
    |> preload(:user)
    |> Repo.paginate(%{"page" => page})

    render conn, "follower.html",
      page: page,
      current_page: nil
  end

  def follower(conn, %{"username" => username}) do
    follower(conn, %{"username" => username, "page" => "1"})
  end

  @doc """
  正在关注
  """
  def followed(conn, %{"username" => username, "page" => page}) do
    user = User |> Repo.get_by!(username: username)

    conn = assign(conn, :title, "#{who(conn, user)}的正在关注")

    page = UserFollow
    |> where(user_id: ^user.id)
    |> order_by(desc: :inserted_at)
    |> preload(:to_user)
    |> Repo.paginate(%{"page" => page})

    render conn, "followed.html",
      page: page,
      current_page: nil
  end

  def followed(conn, %{"username" => username}) do
    followed(conn, %{"username" => username, "page" => "1"})
  end

  def avatar(conn, %{"username" => username}) do
    content = ConCache.get_or_store(:phoenix_china, "avatar:#{username}", fn() ->
      user = User |> Repo.get_by!(username: username)
      url = cond do
              !is_nil(user.avatar) -> user.avatar
              true -> user |> generate_avatar_url
            end
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
