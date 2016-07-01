defmodule PhoenixChina.User do
  use PhoenixChina.Web, :model

  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :avatar, :string
    field :nickname, :string

    field :password, :string, virtual: true
    
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :password, :nickname])
    |> validate_required([:email, :password, :nickname])
  end
end
