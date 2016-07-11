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
    |> strip_unsafe_content(params)
  end

  defp strip_unsafe_content(struct, %{"content" => nil}) do
    struct
  end

  defp strip_unsafe_content(struct, %{"content" => body}) do
    {:safe, clean_body} = Phoenix.HTML.html_escape(body)
    struct |> put_change(:content, clean_body)
  end

  defp strip_unsafe_content(struct, _) do
    struct
  end

  def inc(%__MODULE__{:id => comment_id}, :praise_count) do
    __MODULE__
    |> where(id: ^comment_id)
    |> update(inc: [praise_count: 1])
    |> Repo.update_all([])
  end

  def dsc(%__MODULE__{:id => comment_id}, :praise_count) do
    __MODULE__
    |> where(id: ^comment_id)
    |> update(inc: [praise_count: -1])
    |> Repo.update_all([])
  end
end
