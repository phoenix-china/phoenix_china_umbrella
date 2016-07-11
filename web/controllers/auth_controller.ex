defmodule PhoenixChina.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """

  use PhoenixChina.Web, :controller
  plug Ueberauth

  alias Ueberauth.Strategy.Helpers


  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "授权失败.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user = auth.extra.raw_info.user
    # id bio login, html_url
    IO.inspect auth
    text conn, "回调"

    # case UserFromAuth.find_or_create(auth) do
    #   {:ok, user} ->
    #     conn
    #     |> put_flash(:info, "Successfully authenticated.")
    #     |> put_session(:current_user, user)
    #     |> redirect(to: "/")
    #   {:error, reason} ->
    #     conn
    #     |> put_flash(:error, reason)
    #     |> redirect(to: "/")
    # end
  end
end
