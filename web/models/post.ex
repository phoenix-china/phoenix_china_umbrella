defmodule PhoenixChina.Post do
  use PhoenixChina.Web, :model
  alias PhoenixChina.Comment

  schema "posts" do
    field :title, :string
    field :content, :string
    belongs_to :user, PhoenixChina.User
    has_many :comments, Comment, on_delete: :delete_all

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :content])
    |> validate_required([:title, :content])
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
end
