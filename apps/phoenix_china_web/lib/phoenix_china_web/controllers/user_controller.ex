defmodule PhoenixChina.Web.UserController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.UserContext

  @doc """
  用户注册页面
  """
  def new(conn, _params) do
    changeset = UserContext.change_user(:create)

    conn
    |> assign(:title, "用户注册")
    |> assign(:changeset, changeset)
    |> render("new.html")
  end

  @doc """
  用户注册提交表单
  """
  def create(conn, %{"user" => user_params}) do
    with {:ok, _user} <- UserContext.create(user_params) do
      conn
      |> put_flash(:info, "注册成功！")
      |> redirect(to: page_path(conn, :index))
    else
      {:error, changeset} ->
        conn
        |> assign(:title, "用户注册")
        |> assign(:changeset, changeset)
        |> render("new.html")
    end
  end
end
