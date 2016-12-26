defmodule PhoenixChina.Guardian.Serializer do
  @behaviour Guardian.Serializer

  alias PhoenixChina.{Repo, User}

  require Ecto.Query

  def for_token(user = %User{}), do: { :ok, "User:#{user.id}" }
  def for_token(_), do: { :error, "Unknown resource type" }

  def from_token("User:" <> id), do: { :ok, User |> Ecto.Query.preload([:github]) |> Repo.get(id) }
  def from_token(_), do: { :error, "Unknown resource type" }
end