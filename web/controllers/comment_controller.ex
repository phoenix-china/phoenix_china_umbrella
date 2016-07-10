defmodule PhoenixChina.CommentController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.LayoutView
  alias PhoenixChina.Comment
  alias PhoenixChina.Post
  import PhoenixChina.ViewHelpers, only: [current_user: 1]

  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixChina.GuardianHandler]
    when action in [:create, :edit, :update, :delete]
  plug PhoenixChina.GuardianPlug

  def show(conn, %{"post_id" => post_id, "id" => comment_id}) do
    post = Post |> where(id: ^post_id) |> preload([:user, :latest_comment, latest_comment: :user]) |> Repo.one!
    comment = Comment |> where(id: ^comment_id) |> preload(:user) |> Repo.one!
    render conn, "post.html",
      layout: {LayoutView, "base.html"},
      post: post,
      comment: comment
  end

  def create(conn, %{"post_id" => post_id, "comment" => comment_params}) do
    current_user = current_user(conn)
    changeset = Comment.changeset(%Comment{}, comment_params)
    |> Ecto.Changeset.put_change(:post_id, String.to_integer(post_id))
    |> Ecto.Changeset.put_change(:user_id, current_user.id)

    case Repo.insert(changeset) do
      {:ok, comment} ->
        comment_after_insert(comment)
        conn
        |> put_flash(:info, "评论创建成功.")
        |> redirect(to: post_path(conn, :show, post_id))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, post_id: post_id)
    end
  end

  def edit(conn, %{"post_id" => post_id, "id" => id}) do
    current_user = current_user(conn)
    comment = Repo.get!(Comment, id)

    case comment.user_id == current_user.id do
      false ->
        conn
        |> put_flash(:info, "不是自己的评论，不允许编辑！")
        |> redirect(to: post_path(conn, :show, post_id))

      true ->
        changeset = Comment.changeset(comment)
        render(conn, "edit.html", post_id: post_id, comment: comment, changeset: changeset)
    end
  end

  def update(conn, %{"post_id" => post_id, "id" => id, "comment" => comment_params}) do
    current_user = current_user(conn)
    comment = Repo.get!(Comment, id)

    case comment.user_id == current_user.id do
      false ->
        conn
        |> put_flash(:info, "不是自己的评论，不允许编辑！")
        |> redirect(to: post_path(conn, :show, post_id))

      true ->
        changeset = Comment.changeset(comment, comment_params)

        case Repo.update(changeset) do
          {:ok, _comment} ->
            conn
            |> put_flash(:info, "评论更新成功！")
            |> redirect(to: post_path(conn, :show, post_id))
          {:error, changeset} ->
            render(conn, "edit.html", comment: comment, changeset: changeset)
        end
    end
  end

  def delete(conn, %{"post_id" => post_id, "id" => id}) do
    current_user = current_user(conn)
    comment = Repo.get!(Comment, id)

    case comment.user_id == current_user.id do
      false ->
        conn
        |> put_flash(:info, "不是自己的评论，不允许删除！")
        |> redirect(to: post_path(conn, :show, post_id))

      true ->
        comment_before_delete(comment)
        Repo.delete!(comment)

        conn
        |> put_flash(:info, "评论删除成功！")
        |> redirect(to: post_path(conn, :show, post_id))
    end
  end

  defp update_post_latest_comment_id(post, comment_id) do
    changeset = Post.changeset(:update, post, %{"latest_comment_id" => comment_id})
    Repo.update(changeset)
  end

  defp update_post_comment_count(post, num) do
    changeset = Post.changeset(:update, post, %{"comment_count" => post.comment_count + num})
    Repo.update(changeset)
  end

  defp comment_after_insert(comment) do
    post = Post |> where(id: ^comment.post_id) |> Repo.one!
    update_post_latest_comment_id(post, comment.id)
    update_post_comment_count(post, 1)
  end

  defp comment_before_delete(comment) do
    post = Post |> where(id: ^comment.post_id) |> Repo.one!

    comment_id = Comment
    |> where([c], c.post_id == ^comment.post_id and c.id != ^comment.id)
    |> select([u], max(u.id))
    |> Repo.one

    update_post_latest_comment_id(post, comment_id)
    update_post_comment_count(post, -1)
  end

end
