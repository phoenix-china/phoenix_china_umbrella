defmodule PhoenixChina.UserFollowControllerTest do
  use PhoenixChina.ConnCase

  alias PhoenixChina.UserFollow
  @valid_attrs %{}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, user_follow_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing user follows"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, user_follow_path(conn, :new)
    assert html_response(conn, 200) =~ "New user follow"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, user_follow_path(conn, :create), user_follow: @valid_attrs
    assert redirected_to(conn) == user_follow_path(conn, :index)
    assert Repo.get_by(UserFollow, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_follow_path(conn, :create), user_follow: @invalid_attrs
    assert html_response(conn, 200) =~ "New user follow"
  end

  test "shows chosen resource", %{conn: conn} do
    user_follow = Repo.insert! %UserFollow{}
    conn = get conn, user_follow_path(conn, :show, user_follow)
    assert html_response(conn, 200) =~ "Show user follow"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, user_follow_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    user_follow = Repo.insert! %UserFollow{}
    conn = get conn, user_follow_path(conn, :edit, user_follow)
    assert html_response(conn, 200) =~ "Edit user follow"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    user_follow = Repo.insert! %UserFollow{}
    conn = put conn, user_follow_path(conn, :update, user_follow), user_follow: @valid_attrs
    assert redirected_to(conn) == user_follow_path(conn, :show, user_follow)
    assert Repo.get_by(UserFollow, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    user_follow = Repo.insert! %UserFollow{}
    conn = put conn, user_follow_path(conn, :update, user_follow), user_follow: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit user follow"
  end

  test "deletes chosen resource", %{conn: conn} do
    user_follow = Repo.insert! %UserFollow{}
    conn = delete conn, user_follow_path(conn, :delete, user_follow)
    assert redirected_to(conn) == user_follow_path(conn, :index)
    refute Repo.get(UserFollow, user_follow.id)
  end
end
