defmodule PhoenixChina.Post do
  use PhoenixChina.Web, :model
  alias PhoenixChina.Comment

  schema "posts" do
    field :title, :string
    field :content, :string
    belongs_to :user, PhoenixChina.User
    has_many :comments, Comment, on_delete: :delete_all

    # 评论数量
    field :comment_count, :integer, default: 0
    # 收藏数量
    field :collect_count, :integer, default: 0
    # 点赞数量
    field :praise_count, :integer, default: 0
    # 最新一个评论
    belongs_to :latest_comment, PhoenixChina.Comment, foreign_key: :latest_comment_id

    timestamps()
  end

  @required_params [:title, :content, :user_id]
  @optional_params [:comment_count, :collect_count, :praise_count, :latest_comment_id]


  def changeset(action, struct, params \\ %{})

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(:insert, struct, params) do
    struct
    |> cast(params, @required_params, @optional_params)
    |> validate_required(@required_params)
    |> strip_unsafe_content(params)
  end

  def changeset(:update, struct, params) do
    struct
    |> cast(params, @required_params, @optional_params)
    |> validate_required(@required_params)
    |> strip_unsafe_content(params)
  end

  defp strip_unsafe_content(struct, %{"content" => nil}) do
    struct
  end

  defp strip_unsafe_content(struct, %{"content" => body}) do
    {:safe, clean_body} = Phoenix.HTML.html_escape(body)
    struct |> put_change(:content, clean_body)
  end

  defp strip_unsafe_content(struct, _) do
    struct
  end

  def inc_collect_count(post_id, value) do
    from(p in __MODULE__, where: p.id == ^post_id, update: [inc: [collect_count: ^value]])
    |> PhoenixChina.Repo.update_all([])
  end
end
