defmodule PhoenixChina.UserGithub do
  use PhoenixChina.Web, :model

  schema "users_github" do
    field :github_id, :string
    field :github_url, :string
    belongs_to :user, PhoenixChina.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:github_id, :github_url])
    |> validate_required([:github_id, :github_url])
  end
end
