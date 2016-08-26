defmodule PhoenixChina.PageControllerTest do
  use PhoenixChina.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Phoenix中文社区"
  end

  test "GET / pages", %{conn: conn} do
    conn = get conn, "/?page=1"
    assert html_response(conn, 200) =~ "Phoenix中文社区"
  end

  test "GET / labels", %{conn: conn} do
    conn = get conn, "/?label=全部"
    assert html_response(conn, 200) =~ "Phoenix中文社区"
  end

  test "GET / labels and pages", %{conn: conn} do
    conn = get conn, "/?label=全部&page=1"
    assert html_response(conn, 200) =~ "Phoenix中文社区"
  end

  test "GET /room", %{conn: conn} do
    conn = get conn, "/room"
    assert html_response(conn, 200) =~ "Phoenix中文社区"
  end

  test "GET /commits", %{conn: conn} do
    conn = get conn, "/commits"
    assert html_response(conn, 200) =~ "Phoenix中文社区"
  end
end
