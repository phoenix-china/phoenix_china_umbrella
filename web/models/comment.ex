defmodule PhoenixChina.Comment do
  use PhoenixChina.Web, :model

  schema "comments" do
    field :content, :string
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
    |> after_insert
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

  defp after_insert(struct) do
    case struct.data do
      %{"id" => id} ->
         Post |> update(set: [latest_comment_id: ^id])
      _ ->
        IO.inspect struct
        struct
    end
  end
end
