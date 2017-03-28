defmodule PhoenixChina.Guardian.Serializer do
  @behaviour Guardian.Serializer

  alias PhoenixChina.Models.User
  alias PhoenixChina.UserContext

  def for_token(user = %User{}), do: { :ok, "User:#{user.id}" }
  def for_token(_), do: { :error, "Unknown resource type" }

  def from_token("User:" <> id), do: { :ok, UserContext.get(id) }
  def from_token(_), do: { :error, "Unknown resource type" }
end