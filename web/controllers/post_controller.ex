defmodule PhoenixChina.PostController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.{User, Post, PostLabel, Comment, Notification}

  import PhoenixChina.ViewHelpers, only: [current_user: 1, admin_logged_in?: 1]
  import PhoenixChina.Ecto.Helpers, only: [increment: 2]

  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixChina.GuardianErrorHandler]
    when action in [:new, :create, :edit, :update, :delete]

  def new(conn, _params) do
    changeset = Post.changeset(:insert, %Post{})
    labels = PostLabel |> where(is_hide: false) |> order_by(:order) |> Repo.all

    conn
    |> assign(:title, "发布帖子")
    |> assign(:labels, labels)
    |> assign(:changeset, changeset)
    |> render("new.html")
  end

  def create(conn, %{"post" => post_params}) do
    current_user = current_user(conn)
    post_params = post_params
    |> Dict.put_new("user_id", current_user.id)
    changeset = Post.changeset(:insert, %Post{}, post_params)

    case Repo.insert(changeset) do
      {:ok, post} ->
        Enum.map(Regex.scan(~r/@(\S+)\s?/, post.content), fn [_, username] ->
          user = User |> Repo.get_by(username: username)

          if user && (user != current_user) do

            notification_html = Notification.render "at_post.html",
              conn: conn,
              user: current_user,
              post: post

            Notification.publish(
              "at_post",
              user.id,
              current_user.id,
              post.id,
              notification_html
            )

            user |> increment(:unread_notifications_count)
          end
        end)

        conn
        |> put_flash(:info, "帖子发布成功.")
        |> redirect(to: page_path(conn, :index))
      {:error, changeset} ->
        labels = PostLabel |> where(is_hide: false) |> order_by(:order) |> Repo.all

        conn
        |> assign(:title, "发布帖子")
        |> assign(:labels, labels)
        |> assign(:changeset, changeset)
        |> render("new.html")
    end
  end

  def show(conn, %{"id" => id}) do
    post = Post
    |> preload([:label, :user, :latest_comment, latest_comment: :user])
    |> Repo.get!(id)

    comments = Comment
    |> where(post_id: ^id)
    |> order_by(asc: :index)
    |> preload([:user])
    |> Repo.all

    changeset = Comment.changeset(%Comment{})

    conn
    |> assign(:title, post.title)
    |> assign(:post, post)
    |> assign(:comments, comments)
    |> assign(:changeset, changeset)
    |> render("show.html")
  end

  def edit(conn, %{"id" => id}) do
    current_user = current_user(conn)
    post = Repo.get_by!(Post, id: id, user_id: current_user.id)

    changeset = Post.changeset(:update, post)
    labels = PostLabel |> where(is_hide: false) |> order_by(:order) |> Repo.all

    conn
    |> assign(:title, "编辑帖子")
    |> assign(:labels, labels)
    |> assign(:post, post)
    |> assign(:changeset, changeset)
    |> render("edit.html")
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    current_user = current_user(conn)
    post = Repo.get_by!(Post, id: id, user_id: current_user.id)

    changeset = Post.changeset(:update, post, post_params)

    case Repo.update(changeset) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "帖子更新成功.")
        |> redirect(to: post_path(conn, :show, post))
      {:error, changeset} ->
        labels = PostLabel |> where(is_hide: false) |> order_by(:order) |> Repo.all

        conn
        |> assign(:title, "编辑帖子")
        |> assign(:labels, labels)
        |> assign(:post, post)
        |> assign(:changeset, changeset)
        |> render("edit.html")
    end
  end

  def delete(conn, %{"id" => id}) do
    current_user = current_user(conn)

    Post
    |> Repo.get_by!(Post, id: id, user_id: current_user.id)
    |> Repo.delete!

    conn
    |> put_flash(:info, "帖子删除成功")
    |> redirect(to: page_path(conn, :index))
  end
end
