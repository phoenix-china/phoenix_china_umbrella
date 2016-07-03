defmodule PhoenixChina.CommentControllerTest do
  use PhoenixChina.ConnCase

  alias PhoenixChina.Comment
  @valid_attrs %{content: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, comment_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing comments"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, comment_path(conn, :new)
    assert html_response(conn, 200) =~ "New comment"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, comment_path(conn, :create), comment: @valid_attrs
    assert redirected_to(conn) == comment_path(conn, :index)
    assert Repo.get_by(Comment, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, comment_path(conn, :create), comment: @invalid_attrs
    assert html_response(conn, 200) =~ "New comment"
  end

  test "shows chosen resource", %{conn: conn} do
    comment = Repo.insert! %Comment{}
    conn = get conn, comment_path(conn, :show, comment)
    assert html_response(conn, 200) =~ "Show comment"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, comment_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    comment = Repo.insert! %Comment{}
    conn = get conn, comment_path(conn, :edit, comment)
    assert html_response(conn, 200) =~ "Edit comment"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    comment = Repo.insert! %Comment{}
    conn = put conn, comment_path(conn, :update, comment), comment: @valid_attrs
    assert redirected_to(conn) == comment_path(conn, :show, comment)
    assert Repo.get_by(Comment, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    comment = Repo.insert! %Comment{}
    conn = put conn, comment_path(conn, :update, comment), comment: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit comment"
  end

  test "deletes chosen resource", %{conn: conn} do
    comment = Repo.insert! %Comment{}
    conn = delete conn, comment_path(conn, :delete, comment)
    assert redirected_to(conn) == comment_path(conn, :index)
    refute Repo.get(Comment, comment.id)
  end
end
