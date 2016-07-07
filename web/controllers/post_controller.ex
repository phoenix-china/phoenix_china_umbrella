defmodule PhoenixChina.PostController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.Post
  alias PhoenixChina.Comment
  import PhoenixChina.ViewHelpers, only: [current_user: 1]

  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixChina.GuardianHandler]
  when action in [:new, :create, :edit, :update, :delete]
  plug PhoenixChina.GuardianPlug

  def index(conn, _params) do
    posts = (from Post, order_by: [desc: :inserted_at], preload: [:user])
    |> Repo.all
    render(conn, "index.html", posts: posts)
  end

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
      {:ok, _post} ->
        conn
        |> put_flash(:info, "帖子发布成功.")
        |> redirect(to: page_path(conn, :index))
      {:error, changeset} ->
        IO.inspect changeset
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    IO.inspect conn
    post = (from Post, where: [id: ^id], preload: [:user, :latest_comment, latest_comment: :user]) |> first |> Repo.one!
    comments = (from Comment, where: [post_id: ^id], order_by: [asc: :inserted_at], preload: [:user])
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
        Repo.delete!(post)

        conn
        |> put_flash(:info, "帖子删除成功")
        |> redirect(to: page_path(conn, :index))
    end
  end
end
