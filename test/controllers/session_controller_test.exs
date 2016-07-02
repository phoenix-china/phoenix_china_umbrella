defmodule PhoenixChina.SessionControllerTest do
  use PhoenixChina.ConnCase

  alias PhoenixChina.Session
  @valid_attrs %{}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, session_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing session"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, session_path(conn, :new)
    assert html_response(conn, 200) =~ "New session"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: @valid_attrs
    assert redirected_to(conn) == session_path(conn, :index)
    assert Repo.get_by(Session, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: @invalid_attrs
    assert html_response(conn, 200) =~ "New session"
  end

  test "shows chosen resource", %{conn: conn} do
    session = Repo.insert! %Session{}
    conn = get conn, session_path(conn, :show, session)
    assert html_response(conn, 200) =~ "Show session"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, session_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    session = Repo.insert! %Session{}
    conn = get conn, session_path(conn, :edit, session)
    assert html_response(conn, 200) =~ "Edit session"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    session = Repo.insert! %Session{}
    conn = put conn, session_path(conn, :update, session), session: @valid_attrs
    assert redirected_to(conn) == session_path(conn, :show, session)
    assert Repo.get_by(Session, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    session = Repo.insert! %Session{}
    conn = put conn, session_path(conn, :update, session), session: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit session"
  end

  test "deletes chosen resource", %{conn: conn} do
    session = Repo.insert! %Session{}
    conn = delete conn, session_path(conn, :delete, session)
    assert redirected_to(conn) == session_path(conn, :index)
    refute Repo.get(Session, session.id)
  end
end
