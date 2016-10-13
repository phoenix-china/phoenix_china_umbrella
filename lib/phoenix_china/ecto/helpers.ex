defmodule PhoenixChina.Ecto.Helpers do
  @moduledoc """

  example:
    post = Repo.get(Post, post_id)

    post |> increment(:comment_count)
    post |> increment(:comment_count, 1)
    post |> decrement(:comment_count, 2)
  """
  alias PhoenixChina.Repo

  def increment(struct, field, step \\ 1) do
    params = %{}
    |> Map.put_new(field, Map.get(struct, field))
    |> Map.update!(field, &(&1 + step))

    update_struct(struct, params)
  end

  def decrement(struct, field, step \\ 1) do
    increment(struct, field, -step)
  end

  def update_field(struct, field, value) do
    params = %{}
    |> Map.put_new(field, value)

    update_struct(struct, params)
  end

  defp update_struct(struct, params) do
    {:ok, struct} = struct
    |> Ecto.Changeset.change(params)
    |> Repo.update

    struct
  end
end
