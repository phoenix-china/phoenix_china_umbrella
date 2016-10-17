defmodule PhoenixChina.CommentPraise do
  use PhoenixChina.Web, :model

  schema "comment_praises" do
    belongs_to :user, PhoenixChina.User
    belongs_to :comment, PhoenixChina.Comment

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :comment_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:comment)
  end
end
