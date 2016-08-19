defmodule PhoenixChina.AuthController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.{User, UserGithub}

  plug Ueberauth


  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "授权失败.")
    |> redirect(to: page_path(conn, :index))
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    create_github = fn user, github_data ->
      user_data = github_data.extra.raw_info.user

      Repo.insert(%UserGithub{
        "github_id": Integer.to_string(user_data["id"]),
        "github_url": user_data["html_url"],
        "user_id": user.id
      })

      user
    end

    generate_username = fn github_data ->
      username = github_data.info.nickname

      cond do
        username && is_nil(User |> Repo.get_by(username: username)) -> username
        true ->
          Hashids.new(salt: "phoenix-china-username")
          |> Hashids.encode(:os.system_time(:milli_seconds))
      end
    end

    create_user = fn github_data ->
      user_data = github_data.extra.raw_info.user
      user_email = github_data.info.email

      changeset = User.changeset(:github, %User{}, %{
        "email": user_email,
        "password_hash": nil,
        "username": generate_username.(github_data),
        "nickname": user_data["name"],
        "bio": user_data["bio"],
        "avatar": "#{user_data["avatar_url"]}&s=200"
      })

      case Repo.insert(changeset) do
        {:ok, new_user} ->
          create_github.(new_user, github_data)
        {:error, _} -> nil
      end
    end

    find_user = fn email ->
      User |> preload([:github]) |> Repo.get_by(email: email)
    end

    find_user_github = fn github_data ->
      github_id = Integer.to_string(github_data.extra.raw_info.user["id"])
      UserGithub |> preload([:user]) |> Repo.get_by(github_id: github_id)
    end

    user = case auth.info.email do
      nil ->
        user_github = find_user_github.(auth)

        cond do
          user_github -> user_github.user
          is_nil(user_github) -> create_user.(auth)
          true -> nil
        end

      user_email ->
        user = find_user.(user_email)

        cond do
          user && Enum.count(user.github) > 0 -> user
          user && Enum.count(user.github) == 0 -> create_github.(user, auth)
          is_nil(user) -> create_user.(auth)
          true -> nil
        end
    end

    conn = cond do
      user && user.is_admin ->
        conn
        |> Guardian.Plug.sign_in(user)
        |> Guardian.Plug.sign_in(user, :default, key: :admin)
        |> put_flash(:info, "登录成功！")

      user ->
        conn
        |> Guardian.Plug.sign_in(user)
        |> put_flash(:info, "登录成功！")

      true -> conn |> put_flash(:error, "登录失败！")
    end

    conn |> redirect(to: page_path(conn, :index))
  end
end
