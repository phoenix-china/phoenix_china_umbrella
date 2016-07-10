defmodule PhoenixChina.UserFollow do
  use PhoenixChina.Web, :model

  schema "user_follows" do
    belongs_to :user, PhoenixChina.User
    belongs_to :to_user, PhoenixChina.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :to_user_id])
    |> validate_required([:user_id, :to_user_id])
  end
end
