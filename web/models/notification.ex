defmodule PhoenixChina.Notification do
  use PhoenixChina.Web, :model

  alias PhoenixChina.{Repo, User, Post, Comment, PostPraise, PostCollect, CommentPraise}
  import PhoenixChina.Ecto.Helpers, only: [increment: 2, decrement: 2]

  schema "notificatons" do
    field :action, :string
    field :data_id, :integer
    field :html, :string
    belongs_to :user, PhoenixChina.User
    belongs_to :operator, PhoenixChina.Operator

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:action, :data_id, :html])
    |> validate_required([:action, :data_id, :html])
  end

  def render(template, opts \\ []) do
    Phoenix.View.render_to_string(PhoenixChina.NotificationView, template, opts)
  end

  def publish(action, user_id, operator_id, data_id, notification_html) do
    notification_struct = %__MODULE__{
      user_id: user_id,
      operator_id: operator_id,
      action: action,
      data_id: data_id,
      html: notification_html
    }

    case PhoenixChina.Repo.insert(notification_struct) do
      {:ok, notification} ->
        User |> Repo.get(user_id) |> increment(:unread_notifications_count)

        PhoenixChina.Endpoint.broadcast(
          "notifications:" <> (notification.user_id |> Integer.to_string),
          ":msg",
          %{"body" => notification_html}
        )
      {:error, struct} -> struct
    end
  end

  @doc """
  在评论中@用户
  """
  def create(conn, :at, %Comment{} = comment) do
    comment = comment |> Repo.preload(:user) |> Repo.preload(:post)

    Enum.map(Regex.scan(~r/@(\S+)\s?/, comment.content), fn [_, username] ->
      user = User |> Repo.get_by(username: username)

      if not is_nil(user) and user.id != comment.user_id do
        html = render("at_comment.html", conn: conn, user: comment.user, post: comment.post, comment: comment)
        publish("at_comment", user.id, comment.user_id, comment.id, html)
      end
    end)
  end

  @doc """
  在帖子中@用户
  """
  def create(conn, :at, %Post{} = post) do
    post = post |> Repo.preload(:user)

    Enum.map(Regex.scan(~r/@(\S+)\s?/, post.content), fn [_, username] ->
      user = User |> Repo.get_by(username: username)

      if not is_nil(user) and user.id != post.user_id do
        html = render("at_post.html", conn: conn, user: post.user, post: post)
        publish("at_post", user.id, post.user_id, post.id, html)
      end
    end)
  end

  @doc """
  评论帖子
  """
  def create(conn, %Comment{} = comment) do
    comment = comment |> Repo.preload(:user) |> Repo.preload(:post)

    create(conn, :at, comment)

    if comment.user_id != comment.post.user_id do
      html = render("comment.html", conn: conn, user: comment.user, post: comment.post, comment: comment)
      publish("comment_post", comment.post.user_id, comment.user_id, comment.post_id, html)
    end
  end

  @doc """
  收藏帖子
  """
  def create(conn, %PostCollect{} = collect) do
    collect = collect |> Repo.preload(:user) |> Repo.preload(:post)

    if collect.user_id != collect.post.user_id do
      html = render("post_collect.html", conn: conn, user: collect.user, post: collect.post)
      publish("post_collect", collect.post.user_id, collect.user_id, collect.post_id, html)
    end
  end

  @doc """
  点赞帖子
  """
  def create(conn, %PostPraise{} = praise) do
    praise = praise |> Repo.preload(:user) |> Repo.preload(:post)

    if praise.user_id != praise.post.user_id do
      html = render("post_praise.html", conn: conn, user: praise.user, post: praise.post)
      publish("post_praise", praise.post.user_id, praise.user_id, praise.post_id, html)
    end
  end

  @doc """
  点赞评论
  """
  def create(conn, %CommentPraise{} = praise) do
    praise = praise |> Repo.preload(:user) |> Repo.preload(:comment) |> Repo.preload(comment: :post)

    if praise.user_id != praise.comment.user_id do
      html = render("comment_praise.html", conn: conn, user: praise.user, post: praise.comment.post, comment: praise.comment)
      publish("comment_praise", praise.comment.user_id, praise.user_id, praise.comment_id, html)
    end
  end

  @doc """
  取消收藏帖子
  """
  def delete(%PostCollect{} = collect) do
    collect = collect |> Repo.preload(:user) |> Repo.preload(:post) |> Repo.preload(post: :user)

    if collect.user_id != collect.post.user_id do
      __MODULE__
      |> where(action: "post_collect")
      |> where(user_id: ^collect.post.user_id)
      |> where(operator_id: ^collect.user_id)
      |> where(data_id: ^collect.post_id)
      |> Repo.delete_all

      if collect.post.user.unread_notifications_count > 0 do
        collect.post.user |> decrement(:unread_notifications_count)
      end
    end
  end

  @doc """
  取消点赞帖子
  """
  def delete(%PostPraise{} = praise) do
    praise = praise |> Repo.preload(:user) |> Repo.preload(:post) |> Repo.preload(post: :user)

    if praise.user_id != praise.post.user_id do
      __MODULE__
      |> where(action: "post_praise")
      |> where(user_id: ^praise.post.user_id)
      |> where(operator_id: ^praise.user_id)
      |> where(data_id: ^praise.post_id)
      |> Repo.delete_all

      if praise.post.user.unread_notifications_count > 0 do
        praise.post.user |> decrement(:unread_notifications_count)
      end
    end
  end

  @doc """
  取消评论点赞
  """
  def delete(%CommentPraise{} = praise) do
    praise = praise |> Repo.preload(:user) |> Repo.preload(:comment) |> Repo.preload(comment: :user)

    if praise.user_id != praise.comment.user_id do
      __MODULE__
      |> where(action: "comment_praise")
      |> where(user_id: ^praise.comment.user_id)
      |> where(operator_id: ^praise.user_id)
      |> where(data_id: ^praise.comment.id)
      |> Repo.delete_all

      if praise.comment.user.unread_notifications_count > 0 do
        praise.comment.user |> decrement(:unread_notifications_count)
      end
    end
  end
end
