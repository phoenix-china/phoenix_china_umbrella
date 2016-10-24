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

  def create(%Post{} = post) do

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
  取消点赞
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
end
