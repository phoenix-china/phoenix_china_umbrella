defmodule PhoenixChina.CommentController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.LayoutView
  alias PhoenixChina.Comment
  alias PhoenixChina.Post
  alias PhoenixChina.Notification

  import PhoenixChina.ViewHelpers, only: [current_user: 1]
  import PhoenixChina.ModelOperator, only: [set: 4, inc: 3, dec: 3]
  import Phoenix.HTML.Link, only: [link: 2]

  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixChina.GuardianHandler]
    when action in [:create, :edit, :update, :delete]
  plug PhoenixChina.GuardianPlug

  def show(conn, %{"post_id" => post_id, "id" => comment_id}) do
    post = Post
    |> preload([:user, :latest_comment, latest_comment: :user])
    |> Repo.get!(post_id)

    comment = Comment
    |> preload(:user)
    |> Repo.get!(comment_id)

    render conn, "post.html",
      layout: {LayoutView, "base.html"},
      post: post,
      comment: comment
  end

  def create(conn, %{"post_id" => post_id, "comment" => comment_params}) do
    current_user = current_user(conn)
    post = Repo.get!(Post, post_id)
    changeset = Comment.changeset(%Comment{}, comment_params)
    |> Ecto.Changeset.put_change(:post_id, String.to_integer(post_id))
    |> Ecto.Changeset.put_change(:user_id, current_user.id)

    case Repo.insert(changeset) do
      {:ok, comment} ->
        Post |> set(post, :latest_comment_id, comment.id)
        Post |> inc(post, :comment_count)

        if current_user.id != post.user_id do
          notification_html = Phoenix.View.render_to_string(
            PhoenixChina.NotificationView,
            "comment.html",
            conn: conn,
            user: current_user,
            post: post,
            comment: comment
          )

          notification_struct = %Notification{
            user_id: post.user_id,
            operator_id: current_user.id,
            action: "comment_post",
            data_id: post.id,
            html: notification_html,
            json: %{}
          }

          case Repo.insert(notification_struct) do
            {:ok, notification} ->
              PhoenixChina.Endpoint.broadcast(
                "notifications:" <> (post.user_id |> Integer.to_string),
                ":msg",
                %{"body" => notification_html}
              )
            {:error, _} ->
          end
        end

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
    post = Repo.get!(Post, post_id)
    comment = Repo.get!(Comment, id)

    case comment.user_id == current_user.id do
      false ->
        conn
        |> put_flash(:info, "不是自己的评论，不允许删除！")
        |> redirect(to: post_path(conn, :show, post_id))

      true ->
        latest_comment_id = Comment
        |> where([c], c.post_id == ^comment.post_id and c.id != ^comment.id)
        |> select([u], max(u.id))
        |> Repo.one

        Post |> set(post, :latest_comment_id, latest_comment_id)

        Repo.delete!(comment)

        Post |> dec(post, :comment_count)

        conn
        |> put_flash(:info, "评论删除成功！")
        |> redirect(to: post_path(conn, :show, post_id))
    end
  end
end
