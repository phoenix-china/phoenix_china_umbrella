defmodule PhoenixChina.PostCollectControllerTest do
  use PhoenixChina.ConnCase

  alias PhoenixChina.PostCollect
  @valid_attrs %{}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, post_collect_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing post collects"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, post_collect_path(conn, :new)
    assert html_response(conn, 200) =~ "New post collect"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, post_collect_path(conn, :create), post_collect: @valid_attrs
    assert redirected_to(conn) == post_collect_path(conn, :index)
    assert Repo.get_by(PostCollect, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, post_collect_path(conn, :create), post_collect: @invalid_attrs
    assert html_response(conn, 200) =~ "New post collect"
  end

  test "shows chosen resource", %{conn: conn} do
    post_collect = Repo.insert! %PostCollect{}
    conn = get conn, post_collect_path(conn, :show, post_collect)
    assert html_response(conn, 200) =~ "Show post collect"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, post_collect_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    post_collect = Repo.insert! %PostCollect{}
    conn = get conn, post_collect_path(conn, :edit, post_collect)
    assert html_response(conn, 200) =~ "Edit post collect"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    post_collect = Repo.insert! %PostCollect{}
    conn = put conn, post_collect_path(conn, :update, post_collect), post_collect: @valid_attrs
    assert redirected_to(conn) == post_collect_path(conn, :show, post_collect)
    assert Repo.get_by(PostCollect, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    post_collect = Repo.insert! %PostCollect{}
    conn = put conn, post_collect_path(conn, :update, post_collect), post_collect: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit post collect"
  end

  test "deletes chosen resource", %{conn: conn} do
    post_collect = Repo.insert! %PostCollect{}
    conn = delete conn, post_collect_path(conn, :delete, post_collect)
    assert redirected_to(conn) == post_collect_path(conn, :index)
    refute Repo.get(PostCollect, post_collect.id)
  end
end
