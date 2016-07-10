defmodule PhoenixChina.CommentPraiseControllerTest do
  use PhoenixChina.ConnCase

  alias PhoenixChina.CommentPraise
  @valid_attrs %{}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, comment_praise_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing comment praises"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, comment_praise_path(conn, :new)
    assert html_response(conn, 200) =~ "New comment praise"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, comment_praise_path(conn, :create), comment_praise: @valid_attrs
    assert redirected_to(conn) == comment_praise_path(conn, :index)
    assert Repo.get_by(CommentPraise, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, comment_praise_path(conn, :create), comment_praise: @invalid_attrs
    assert html_response(conn, 200) =~ "New comment praise"
  end

  test "shows chosen resource", %{conn: conn} do
    comment_praise = Repo.insert! %CommentPraise{}
    conn = get conn, comment_praise_path(conn, :show, comment_praise)
    assert html_response(conn, 200) =~ "Show comment praise"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, comment_praise_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    comment_praise = Repo.insert! %CommentPraise{}
    conn = get conn, comment_praise_path(conn, :edit, comment_praise)
    assert html_response(conn, 200) =~ "Edit comment praise"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    comment_praise = Repo.insert! %CommentPraise{}
    conn = put conn, comment_praise_path(conn, :update, comment_praise), comment_praise: @valid_attrs
    assert redirected_to(conn) == comment_praise_path(conn, :show, comment_praise)
    assert Repo.get_by(CommentPraise, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    comment_praise = Repo.insert! %CommentPraise{}
    conn = put conn, comment_praise_path(conn, :update, comment_praise), comment_praise: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit comment praise"
  end

  test "deletes chosen resource", %{conn: conn} do
    comment_praise = Repo.insert! %CommentPraise{}
    conn = delete conn, comment_praise_path(conn, :delete, comment_praise)
    assert redirected_to(conn) == comment_praise_path(conn, :index)
    refute Repo.get(CommentPraise, comment_praise.id)
  end
end
