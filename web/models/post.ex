defmodule PhoenixChina.Post do
  use PhoenixChina.Web, :model

  alias PhoenixChina.Repo
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
    |> validate_length(:title, min: 1, max: 140)
    |> validate_length(:content, min: 1, max: 20000)
  end

  def changeset(:update, struct, params) do
    struct
    |> cast(params, @required_params, @optional_params)
    |> validate_required(@required_params)
    |> validate_length(:title, min: 1, max: 140)
    |> validate_length(:content, min: 1, max: 20000)
  end

  def set(%__MODULE__{:id => post_id}, :latest_comment_id, value) do
    __MODULE__
    |> where(id: ^post_id)
    |> update(set: [latest_comment_id: ^value])
    |> Repo.update_all([])
  end

  def inc(module \\ %__MODULE__{}, field)

  def inc(%__MODULE__{:id => post_id}, :comment_count) do
    __MODULE__
    |> where(id: ^post_id)
    |> update(inc: [comment_count: 1])
    |> Repo.update_all([])
  end

  def inc(%__MODULE__{:id => post_id}, :collect_count) do
    __MODULE__
    |> where(id: ^post_id)
    |> update(inc: [collect_count: 1])
    |> Repo.update_all([])
  end

  def inc(%__MODULE__{:id => post_id}, :praise_count) do
    __MODULE__
    |> where(id: ^post_id)
    |> update(inc: [praise_count: 1])
    |> Repo.update_all([])
  end

  def dsc(module \\ %__MODULE__{}, field)

  def dsc(%__MODULE__{:id => post_id}, :comment_count) do
    __MODULE__
    |> where(id: ^post_id)
    |> update(inc: [comment_count: -1])
    |> Repo.update_all([])
  end

  def dsc(%__MODULE__{:id => post_id}, :collect_count) do
    __MODULE__
    |> where(id: ^post_id)
    |> update(inc: [collect_count: -1])
    |> Repo.update_all([])
  end

  def dsc(%__MODULE__{:id => post_id}, :praise_count) do
    __MODULE__
    |> where(id: ^post_id)
    |> update(inc: [praise_count: -1])
    |> Repo.update_all([])
  end
end
