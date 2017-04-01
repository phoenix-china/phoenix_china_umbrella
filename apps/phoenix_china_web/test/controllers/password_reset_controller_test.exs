defmodule PhoenixChina.Web.PasswordResetControllerTest do
  use PhoenixChina.Web.ConnCase

  alias PhoenixChina.UserContext

  @user_attrs %{email: "test@phoenix-china.org", nickname: "test", password: "123456"}
  @email_attrs %{email: "test@phoenix-china.org"}

  def fixture(:user, attrs \\ @user_attrs) do
    {:ok, user} = UserContext.create(attrs)
    user
  end

  test "render form for password reset step 1", %{conn: conn} do
    conn = get conn, password_reset_path(conn, :new)
    assert html_response(conn, 200) =~ "找回密码"
  end

  test "post data for password reset step 2", %{conn: conn} do
    fixture(:user)
    conn = post conn, password_reset_path(conn, :create), password_reset: @email_attrs
    assert html_response(conn, 200) =~ "查看您的电子邮件，并点击其中的链接重置您的密码。如果几分钟后仍然没有收到，请检查您的垃圾邮件文件夹。"
  end

  test "render form for password reset step 3", %{conn: conn} do
    user = fixture(:user)
    token = UserContext.generate_token(user)
    conn = get conn, password_reset_path(conn, :new, token: token)
    assert html_response(conn, 200) =~ "密码重置"
  end

  test "put data for password reset step 4", %{conn: conn} do
    user = fixture(:user)
    token = UserContext.generate_token(user)
    conn = put conn, password_reset_path(conn, :update, token: token), user: %{password: "111111", password_confirmation: "111111"}
    assert redirected_to(conn) == session_path(conn, :create)
  end
end
