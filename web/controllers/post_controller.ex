defmodule PhoenixChina.PostController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.{User, Post, PostLabel, Comment, Notification}

  import PhoenixChina.ViewHelpers, only: [current_user: 1]
  import PhoenixChina.ModelOperator, only: [set: 4, inc: 3]

  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixChina.GuardianErrorHandler]
    when action in [:new, :create, :edit, :update, :delete]
  plug PhoenixChina.GuardianPlug

  def new(conn, _params) do
    changeset = Post.changeset(:insert, %Post{})
    labels = PostLabel |> Repo.all
    render(conn, "new.html", changeset: changeset, labels: labels)
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
        labels = PostLabel |> Repo.all
        render(conn, "new.html", changeset: changeset, labels: labels)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Post
    |> preload([:label, :user, :latest_comment, latest_comment: :user])
    |> Repo.get!(id)

    comments = Comment
    |> where(post_id: ^id)
    |> order_by(asc: :inserted_at)
    |> preload([:user])
    |> Repo.all

    changeset = Comment.changeset(%Comment{})

    conn = assign(conn, :title, post.title)

    render conn, "show.html",
      post: post,
      comments: comments,
      changeset: changeset
  end

  def edit(conn, %{"id" => id}) do
    current_user = current_user(conn)
    post = Repo.get!(Post, id)

    conn = assign(conn, :title, "编辑帖子")

    case post.user_id == current_user.id do
      false ->
        conn
        |> put_flash(:info, "不是自己的帖子，不允许编辑！")
        |> redirect(to: post_path(conn, :show, id))

      true ->
        changeset = Post.changeset(:update, post)
        labels = PostLabel |> Repo.all
        render(conn, "edit.html", post: post, changeset: changeset, labels: labels)
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
            labels = PostLabel |> Repo.all
            render(conn, "edit.html", post: post, changeset: changeset, labels: labels)
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

  def set_top(conn, %{"post_id" => id}) do
    current_user = current_user(conn)

    cond do
      current_user.is_admin ->
        post = Repo.get!(Post, id)
        Post |> set(post, :is_top, true)

        notification_html = Notification.render "post_top.html",
          conn: conn,
          user: current_user,
          post: post

        Notification.publish(
          "post_top",
          post.user_id,
          current_user.id,
          post.id,
          notification_html
        )

        User |> inc(%{id: post.user_id}, :unread_notifications_count)

        conn
        |> put_flash(:info, "置顶成功")
        |> redirect(to: post_path(conn, :show, post))
      true ->
        conn |> redirect(to: page_path(conn, :index))
    end
  end

  def cancel_top(conn, %{"post_id" => id}) do
    current_user = current_user(conn)

    cond do
      current_user.is_admin ->
        post = Repo.get!(Post, id)
        Post |> set(post, :is_top, false)
        conn
        |> put_flash(:info, "取消置顶成功")
        |> redirect(to: post_path(conn, :show, post))
      true ->
        conn |> redirect(to: page_path(conn, :index))
    end
  end
end
