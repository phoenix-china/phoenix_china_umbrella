defmodule PhoenixChina.GuardianSerializer do
  @behaviour Guardian.Serializer

  alias PhoenixChina.Repo
  alias PhoenixChina.User

  def for_token(user = %User{}), do: { :ok, "User:#{user.id}" }
  def for_token(_), do: { :error, "Unknown resource type" }

  def from_token("User:" <> id), do: { :ok, Repo.get(User, String.to_integer(id)) }
  def from_token(_), do: { :error, "Unknown resource type" }

  def unauthenticated(conn, _params) do
    conn
    |> Phoenix.Controller.put_flash(:error, "Authentication required")
    |> Phoenix.Controller.redirect(to: "/signin")
  end
end
