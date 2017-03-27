defmodule PhoenixChina.Web.PageControllerTest do
  use PhoenixChina.Web.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, page_path(conn, :index)
    assert html_response(conn, 200) =~ "Phoenix中文社区"
  end
end
