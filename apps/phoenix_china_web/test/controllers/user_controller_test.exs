defmodule PhoenixChina.Web.UserControllerTest do
  use PhoenixChina.Web.ConnCase

  @create_attrs %{email: "test@phoenix-china.org", nickname: "test", password: "123456"}
  @invalid_attrs %{}

  test "renders form for new users", %{conn: conn} do
    conn = get conn, user_path(conn, :new)
    assert html_response(conn, 200) =~ "用户注册"
  end

  test "creates user and redirects to index when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @create_attrs
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "does not create user and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert html_response(conn, 200) =~ "用户注册"
  end
end
