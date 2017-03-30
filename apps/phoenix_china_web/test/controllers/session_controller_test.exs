defmodule PhoenixChina.Web.SessionControllerTest do
  use PhoenixChina.Web.ConnCase

  alias PhoenixChina.UserContext

  @create_attrs %{email: "test@phoenix-china.org", nickname: "test", password: "123456"}
  @invalid_attrs %{}

  def fixture(:user, attrs \\ @create_attrs) do
    {:ok, user} = UserContext.create(attrs)
    user
  end

  test "renders form for new session", %{conn: conn} do
    conn = get conn, session_path(conn, :new)
    assert html_response(conn, 200) =~ "用户登录"
  end

  test "creates session and redirects to index when data is valid", %{conn: conn} do
    fixture(:user)
    conn = post conn, session_path(conn, :create), session: @create_attrs
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "does not create session and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: @invalid_attrs
    assert html_response(conn, 200) =~ "用户登录"
  end

  test "delete session and redirects to index", %{conn: conn} do
    fixture(:user)
    conn = post conn, session_path(conn, :create), session: @create_attrs
    assert redirected_to(conn) == page_path(conn, :index)

    conn = delete conn, session_path(conn, :delete)
    assert redirected_to(conn) == page_path(conn, :index)

    PhoenixChina.Emails.welcome_email |> PhoenixChina.Mailer.deliver_later
  end
end
