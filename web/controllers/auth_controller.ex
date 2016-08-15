defmodule PhoenixChina.AuthController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.User
  alias PhoenixChina.UserGithub

  plug Ueberauth


  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "授权失败.")
    |> redirect(to: page_path(conn, :index))
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user_data = auth.extra.raw_info.user

    user = case UserGithub |> preload([:user]) |> Repo.get_by(github_id: Integer.to_string(user_data["id"])) do
      nil ->
        s = Hashids.new(salt: "phoenix-china")

        changeset = %User{
          "email": nil,
          "password_hash": nil,
          "nickname": "#{user_data["name"] || auth.info.nickname}-#{Hashids.encode(s, :os.system_time(:milli_seconds))}",
          "bio": user_data["bio"],
          "avatar": "#{user_data["avatar_url"]}&s=200"
        }

        case Repo.insert(changeset) do
          {:ok, user} ->
            Repo.insert(%UserGithub{
              "github_id": Integer.to_string(user_data["id"]),
              "github_url": user_data["html_url"],
              "user_id": user.id
            })
            user
          {:error, _} -> nil
        end
      user_github -> user_github.user
    end

    conn
    |> Guardian.Plug.sign_in(user)
    |> put_flash(:info, "登录成功！")
    |> redirect(to: page_path(conn, :index))
  end
end
