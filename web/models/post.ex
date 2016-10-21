defmodule PhoenixChina.Post do
  use PhoenixChina.Web, :model

  schema "posts" do
    field :title, :string
    field :content, :string
    field :comment_count, :integer, default: 0
    field :collect_count, :integer, default: 0
    field :praise_count, :integer, default: 0
    field :latest_comment_inserted_at, Timex.Ecto.DateTime
    field :is_top, :boolean, default: false
    field :is_closed, :boolean, default: false

    belongs_to :user, PhoenixChina.User
    belongs_to :label, PhoenixChina.PostLabel
    belongs_to :latest_comment, PhoenixChina.Comment, foreign_key: :latest_comment_id
    has_many :comments, PhoenixChina.Comment, on_delete: :delete_all

    timestamps()
  end

  @required_params [:title, :content, :user_id]
  @optional_params [:label_id, :comment_count, :collect_count, :praise_count, :latest_comment_id]

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
    |> put_change(:latest_comment_inserted_at, Timex.now)
    |> assoc_constraint(:user)
  end

  def changeset(:update, struct, params) do
    struct
    |> cast(params, @required_params, @optional_params)
    |> validate_required(@required_params)
    |> validate_length(:title, min: 1, max: 140)
    |> validate_length(:content, min: 1, max: 20000)
  end
end
