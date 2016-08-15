defmodule PhoenixChina.PostLabel do
  use PhoenixChina.Web, :model

  schema "post_labels" do
    field :content, :string

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

  def class(id) do
    classes = %{
      1 => "label-primary",
      2 => "label-success",
      3 => "label-info",
      4 => "label-warning",
      5 => "label-danger",
    }
    Map.get(classes, id, "label-default")
  end
end
