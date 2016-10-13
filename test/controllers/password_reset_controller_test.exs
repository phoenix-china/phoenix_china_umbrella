defmodule PhoenixChina.PasswordResetControllerTest do
  use PhoenixChina.ConnCase

  alias PhoenixChina.PasswordReset
  @valid_attrs %{}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, password_reset_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing password"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, password_reset_path(conn, :new)
    assert html_response(conn, 200) =~ "New password reset"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, password_reset_path(conn, :create), password_reset: @valid_attrs
    assert redirected_to(conn) == password_reset_path(conn, :index)
    assert Repo.get_by(PasswordReset, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, password_reset_path(conn, :create), password_reset: @invalid_attrs
    assert html_response(conn, 200) =~ "New password reset"
  end

  test "shows chosen resource", %{conn: conn} do
    password_reset = Repo.insert! %PasswordReset{}
    conn = get conn, password_reset_path(conn, :show, password_reset)
    assert html_response(conn, 200) =~ "Show password reset"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, password_reset_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    password_reset = Repo.insert! %PasswordReset{}
    conn = get conn, password_reset_path(conn, :edit, password_reset)
    assert html_response(conn, 200) =~ "Edit password reset"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    password_reset = Repo.insert! %PasswordReset{}
    conn = put conn, password_reset_path(conn, :update, password_reset), password_reset: @valid_attrs
    assert redirected_to(conn) == password_reset_path(conn, :show, password_reset)
    assert Repo.get_by(PasswordReset, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    password_reset = Repo.insert! %PasswordReset{}
    conn = put conn, password_reset_path(conn, :update, password_reset), password_reset: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit password reset"
  end

  test "deletes chosen resource", %{conn: conn} do
    password_reset = Repo.insert! %PasswordReset{}
    conn = delete conn, password_reset_path(conn, :delete, password_reset)
    assert redirected_to(conn) == password_reset_path(conn, :index)
    refute Repo.get(PasswordReset, password_reset.id)
  end
end
