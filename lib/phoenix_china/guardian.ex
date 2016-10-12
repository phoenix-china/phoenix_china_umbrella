defmodule PhoenixChina.GuardianErrorHandler do

  def unauthenticated(conn, _params) do
    conn
    |> Phoenix.Controller.put_flash(:error, "哎哟～ 不登录不能操作啊！")
    |> Phoenix.Controller.redirect(to: PhoenixChina.Router.Helpers.session_path(conn, :new))
  end
end


defmodule PhoenixChina.GuardianSerializer do
  @behaviour Guardian.Serializer

  alias PhoenixChina.{Repo, User}

  require Ecto.Query

  def for_token(user = %User{}), do: { :ok, "User:#{user.id}" }
  def for_token(_), do: { :error, "Unknown resource type" }

  def from_token("User:" <> id), do: { :ok, User |> Ecto.Query.preload([:github]) |> Repo.get(id) }
  def from_token(_), do: { :error, "Unknown resource type" }
end
