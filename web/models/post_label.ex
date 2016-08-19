defmodule PhoenixChina.PostLabel do
  use PhoenixChina.Web, :model

  schema "post_labels" do
    field :content, :string
    field :order, :integer
    field :is_hide, :boolean, default: false
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:content])
    |> validate_required([:content])
  end
end
