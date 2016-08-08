defmodule PhoenixChina.ModelOperator do
  import Ecto.Query

  alias PhoenixChina.Repo


  @doc """
  设置某个字段的值
  """
  def set(model, %{:id => id}, field, value) do
    opts = [] |> Keyword.put(field, value)

    model
    |> where(id: ^id)
    |> update(set: ^opts)
    |> Repo.update_all([])
  end

  @doc """
  递增某个字段的值
  """
  def inc(model, %{:id => id}, field) do
    model
    |> where(id: ^id)
    |> inc_or_dec(:inc, field)
  end

  @doc """
  递减某个字段的值
  """
  def dec(model, %{:id => id}, field) do
    model
    |> where(id: ^id)
    |> inc_or_dec(:dec, field)
  end

  defp inc_or_dec(query, action, field, step \\ 1) do
    value = case action do
      :inc -> step
      :dec -> -step
    end

    opts = [] |> Keyword.put(field, value)

    query
    |> update(inc: ^opts)
    |> Repo.update_all([])
  end
end
