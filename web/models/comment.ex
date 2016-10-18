defmodule PhoenixChina.Comment do
  use PhoenixChina.Web, :model

  schema "comments" do
    field :content, :string
    field :index, :integer
    field :praise_count, :integer, default: 0
    field :is_deleted, :boolean, default: false

    belongs_to :user, PhoenixChina.User
    belongs_to :post, PhoenixChina.Post

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:content, :index, :post_id, :user_id])
    |> validate_required([:content, :index])
    |> validate_length(:content, min: 1, max: 200)
    |> assoc_constraint(:user)
    |> assoc_constraint(:post)
  end
end
