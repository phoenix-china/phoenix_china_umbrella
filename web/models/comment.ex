defmodule PhoenixChina.Comment do
  use PhoenixChina.Web, :model

  alias PhoenixChina.Repo

  schema "comments" do
    field :content, :string
    field :praise_count, :integer, default: 0
    belongs_to :user, PhoenixChina.User
    belongs_to :post, PhoenixChina.Post

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:content])
    |> validate_required([:content])
    |> validate_length(:content, min: 1, max: 200)
  end

  defp inc_or_dec(query, action, field, step \\ 1) do
    value = case action do
      :inc -> step
      :dec -> -step
    end

    opts = case field do
      :praise_count ->
        [{:praise_count, value}]
    end

    query
    |> update(inc: ^opts)
    |> Repo.update_all([])
  end

  def inc(%{:id => comment_id}, field) do
    __MODULE__
    |> where(id: ^comment_id)
    |> inc_or_dec(:inc, field)
  end

  def dec(%{:id => comment_id}, field) do
    __MODULE__
    |> where(id: ^comment_id)
    |> inc_or_dec(:dec, field)
  end
end
