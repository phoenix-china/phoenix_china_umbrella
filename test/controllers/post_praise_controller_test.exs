defmodule PhoenixChina.PostPraiseControllerTest do
  use PhoenixChina.ConnCase

  alias PhoenixChina.PostPraise
  @valid_attrs %{}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, post_praise_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing post praises"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, post_praise_path(conn, :new)
    assert html_response(conn, 200) =~ "New post praise"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, post_praise_path(conn, :create), post_praise: @valid_attrs
    assert redirected_to(conn) == post_praise_path(conn, :index)
    assert Repo.get_by(PostPraise, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, post_praise_path(conn, :create), post_praise: @invalid_attrs
    assert html_response(conn, 200) =~ "New post praise"
  end

  test "shows chosen resource", %{conn: conn} do
    post_praise = Repo.insert! %PostPraise{}
    conn = get conn, post_praise_path(conn, :show, post_praise)
    assert html_response(conn, 200) =~ "Show post praise"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, post_praise_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    post_praise = Repo.insert! %PostPraise{}
    conn = get conn, post_praise_path(conn, :edit, post_praise)
    assert html_response(conn, 200) =~ "Edit post praise"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    post_praise = Repo.insert! %PostPraise{}
    conn = put conn, post_praise_path(conn, :update, post_praise), post_praise: @valid_attrs
    assert redirected_to(conn) == post_praise_path(conn, :show, post_praise)
    assert Repo.get_by(PostPraise, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    post_praise = Repo.insert! %PostPraise{}
    conn = put conn, post_praise_path(conn, :update, post_praise), post_praise: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit post praise"
  end

  test "deletes chosen resource", %{conn: conn} do
    post_praise = Repo.insert! %PostPraise{}
    conn = delete conn, post_praise_path(conn, :delete, post_praise)
    assert redirected_to(conn) == post_praise_path(conn, :index)
    refute Repo.get(PostPraise, post_praise.id)
  end
end
