defmodule PhoenixChina.SessionController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.User
  plug PhoenixChina.GuardianPlug

  def new(conn, _params) do
    changeset = User.changeset(:signin, %User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params, "luotest_response" => luotest_response }) do
    changeset = User.changeset(:signin, %User{}, user_params |> Dict.put_new("luotest_response", luotest_response))
    
    case changeset.valid? do
      true ->
        user = User |> Repo.get_by!(email: changeset.changes.email)

        conn
        |> Guardian.Plug.sign_in(user)
        |> put_flash(:info, "登录成功！")
        |> redirect(to: page_path(conn, :index))
      false ->
        changeset = %{changeset | action: :signin}
        render(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, _params) do
    Guardian.Plug.sign_out(conn)
    |> put_flash(:info, "已退出登录")
    |> redirect(to: page_path(conn, :index))
  end
end
