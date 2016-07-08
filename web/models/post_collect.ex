defmodule PhoenixChina.PostCollect do
  use PhoenixChina.Web, :model

  schema "post_collects" do
    belongs_to :user, PhoenixChina.User
    belongs_to :post, PhoenixChina.Post

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :post_id])
    |> validate_required([:user_id, :post_id])
  end
end
