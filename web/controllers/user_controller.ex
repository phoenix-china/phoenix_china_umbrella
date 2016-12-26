defmodule PhoenixChina.UserController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.{User, Post, Comment, PostCollect, UserFollow}

  import PhoenixChina.ViewHelpers, only: [current_user: 1]

  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixChina.Guardian.ErrorHandler]
    when action in [:edit, :update]

  def new(conn, _params) do
    changeset = User.changeset(:signup, %User{})

    conn
    |> assign(:title, "用户注册")
    |> assign(:changeset, changeset)
    |> render("new.html")
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(:signup, %User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "注册成功了！")
        |> Guardian.Plug.sign_in(user)
        |> redirect(to: page_path(conn, :index))
      {:error, changeset} ->
        conn
        |> assign(:title, "用户注册")
        |> assign(:changeset, changeset)
        |> render("new.html")
    end
  end

  @doc """
  主页
  """
  def show(conn, %{"username" => username, "tab" => "index"}) do
    # user = Repo.get_by(User, %{username: username})
    #
    # conn
    # |> assign(:title, user.username <> " 的主页")
    # |> assign(:user, user)
    # |> assign(:current_tab, "index")
    # |> render("show-index.html")
    show(conn, %{"username" => username, "tab" => "post"})
  end

  @doc """
  帖子
  """
  def show(conn, %{"username" => username, "tab" => "post"} = params) do
    user = Repo.get_by!(User, %{username: username})

    pagination = Post
    |> where(user_id: ^user.id)
    |> order_by([desc: :inserted_at])
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
    user = Repo.get_by!(User, %{username: username})

    pagination = Comment
    |> where(user_id: ^user.id)
    |> where(is_deleted: false)
    |> order_by([desc: :inserted_at])
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
    user = Repo.get_by!(User, %{username: username})

    pagination = Post
    |> join(:inner, [p], c in PostCollect, c.post_id == p.id and c.user_id == ^user.id)
    |> order_by([desc: :inserted_at])
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
    user = Repo.get_by!(User, %{username: username})

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
    user = Repo.get_by!(User, %{username: username})

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

  def edit(conn, %{"page" => "profile"}) do
    current_user = current_user(conn)
    changeset = User.changeset(:profile, current_user)

    conn
    |> assign(:title, "修改个人信息")
    |> assign(:current_page, "profile")
    |> assign(:changeset, changeset)
    |> render("edit-profile.html")
  end

  def edit(conn, %{"page" => "password"}) do
    current_user = current_user(conn)
    changeset = User.changeset(:account, current_user)

    conn
    |> assign(:title, "修改密码")
    |> assign(:current_page, "password")
    |> assign(:changeset, changeset)
    |> render("edit-password.html")
  end

  def update(conn, %{"page" => "profile", "user" => user_params}) do
    user = current_user(conn)

    #upload to qiniu
    user_params = case is_nil(user_params["avatar"]) do
      true -> user_params
      false ->
        [filename, url] = PhoenixChina.Qiniu.filename_and_url(user_params["avatar"])
        PhoenixChina.Qiniu.upload(user_params["avatar"], filename)
        %{user_params | "avatar" => url <> "?imageView2/1/w/200/h/200"}
    end

    changeset = User.changeset(:profile, user, user_params)

    case Repo.update(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "个人信息编辑成功！")
        |> redirect(to: user_path(conn, :edit, "profile"))
      {:error, changeset} ->
        conn
        |> assign(:title, "修改个人信息")
        |> assign(:current_page, "profile")
        |> assign(:changeset, changeset)
        |> render("edit-profile.html")
    end
  end

  def update(conn, %{"page" => "password", "user" => user_params}) do
    current_user = current_user(conn)
    changeset = User.changeset(:account, current_user, user_params)

    case Repo.update(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "密码修改成功！")
        |> redirect(to: user_path(conn, :edit, "password"))
      {:error, changeset} ->
        conn
        |> assign(:title, "修改密码")
        |> assign(:current_page, "password")
        |> assign(:changeset, changeset)
        |> render("edit-password.html")
    end
  end
end
