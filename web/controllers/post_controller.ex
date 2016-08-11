defmodule PhoenixChina.PostController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.User
  alias PhoenixChina.Post
  alias PhoenixChina.Comment
  alias PhoenixChina.Notification

  import PhoenixChina.ViewHelpers, only: [current_user: 1]
  import PhoenixChina.ModelOperator, only: [set: 4, inc: 3]

  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixChina.GuardianHandler]
    when action in [:new, :create, :edit, :update, :delete]
  plug PhoenixChina.GuardianPlug

  def new(conn, _params) do
    changeset = Post.changeset(:insert, %Post{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    current_user = current_user(conn)
    post_params = post_params
    |> Dict.put_new("user_id", current_user.id)
    changeset = Post.changeset(:insert, %Post{}, post_params)

    case Repo.insert(changeset) do
      {:ok, post} ->
        Enum.map(Regex.scan(~r/@(\S+)\s?/, post.content), fn [_, nickname] ->
          user = User |> Repo.get_by(nickname: nickname)

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

            User |> inc(user, :unread_notifications_count)
          end
        end)

        conn
        |> put_flash(:info, "帖子发布成功.")
        |> redirect(to: page_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Post
    |> preload([:user, :latest_comment, latest_comment: :user])
    |> Repo.get!(id)

    comments = Comment
    |> where(post_id: ^id)
    |> order_by(asc: :inserted_at)
    |> preload([:user])
    |> Repo.all

    changeset = Comment.changeset(%Comment{})

    render conn, "show.html",
      post: post,
      comments: comments,
      changeset: changeset
  end

  def edit(conn, %{"id" => id}) do
    current_user = current_user(conn)
    post = Repo.get!(Post, id)

    case post.user_id == current_user.id do
      false ->
        conn
        |> put_flash(:info, "不是自己的帖子，不允许编辑！")
        |> redirect(to: post_path(conn, :show, id))

      true ->
        changeset = Post.changeset(:update, post)
        render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    current_user = current_user(conn)
    post = Repo.get!(Post, id)

    case post.user_id == current_user.id do
      false ->
        conn
        |> put_flash(:info, "不是自己的帖子，不允许编辑！")
        |> redirect(to: post_path(conn, :show, id))

      true ->
        changeset = Post.changeset(:update, post, post_params)

        case Repo.update(changeset) do
          {:ok, post} ->
            conn
            |> put_flash(:info, "帖子更新成功.")
            |> redirect(to: post_path(conn, :show, post))
          {:error, changeset} ->
            render(conn, "edit.html", post: post, changeset: changeset)
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    current_user = current_user(conn)
    post = Repo.get!(Post, id)

    case post.user_id == current_user.id do
      false ->
        conn
        |> put_flash(:info, "不是自己的帖子，不允许删除！")
        |> redirect(to: post_path(conn, :show, id))

      true ->
        Post |> set(post, :latest_comment_id, nil)
        Repo.delete!(post)

        conn
        |> put_flash(:info, "帖子删除成功")
        |> redirect(to: page_path(conn, :index))
    end
  end
end
