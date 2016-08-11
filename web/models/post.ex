defmodule PhoenixChina.Post do
  use PhoenixChina.Web, :model

  alias PhoenixChina.Repo
  alias PhoenixChina.User
  alias PhoenixChina.Comment

  schema "posts" do
    field :title, :string
    field :content, :string
    belongs_to :user, User
    has_many :comments, Comment, on_delete: :delete_all

    # 评论数量
    field :comment_count, :integer, default: 0
    # 收藏数量
    field :collect_count, :integer, default: 0
    # 点赞数量
    field :praise_count, :integer, default: 0
    # 最新一个评论
    belongs_to :latest_comment, Comment, foreign_key: :latest_comment_id
    # 最新一条评论的创建时间
    field :latest_comment_inserted_at, Ecto.DateTime;

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
    |> validate_length(:title, min: 1, max: 140)
    |> validate_length(:content, min: 1, max: 20000)
    |> put_change(:latest_comment_inserted_at, Ecto.DateTime.utc)
  end

  def changeset(:update, struct, params) do
    struct
    |> cast(params, @required_params, @optional_params)
    |> validate_required(@required_params)
    |> validate_length(:title, min: 1, max: 140)
    |> validate_length(:content, min: 1, max: 20000)
  end
end
