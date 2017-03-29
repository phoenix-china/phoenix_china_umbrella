defmodule PhoenixChina.Web.SessionController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.SessionContext

  @doc """
  用户登录页面
  """
  def new(conn, _params) do
    changeset = SessionContext.change_session()

    conn
    |> assign(:title, "用户登录")
    |> assign(:changeset, changeset)
    |> render("new.html")
  end

  @doc """
  用户登录提交表单
  """
  def create(conn, %{"session" => user_params}) do
    with {:ok, user} <- SessionContext.create(user_params) do
      conn
      |> Guardian.Plug.sign_in(user)
      |> put_flash(:info, "登录成功！")
      |> redirect(to: page_path(conn, :index))
    else
      {:error, changeset} ->
        conn
        |> assign(:title, "用户登录")
        |> assign(:changeset, changeset)
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> Guardian.Plug.sign_out
    |> put_flash(:info, "已退出登录")
    |> redirect(to: page_path(conn, :index))
  end
end
