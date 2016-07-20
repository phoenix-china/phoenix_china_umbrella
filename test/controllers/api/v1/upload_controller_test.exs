defmodule PhoenixChina.API.V1.UploadControllerTest do
  use PhoenixChina.ConnCase

  alias PhoenixChina.API.V1.Upload
  @valid_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, upload_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    upload = Repo.insert! %Upload{}
    conn = get conn, upload_path(conn, :show, upload)
    assert json_response(conn, 200)["data"] == %{"id" => upload.id}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, upload_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, upload_path(conn, :create), upload: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Upload, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, upload_path(conn, :create), upload: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    upload = Repo.insert! %Upload{}
    conn = put conn, upload_path(conn, :update, upload), upload: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Upload, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    upload = Repo.insert! %Upload{}
    conn = put conn, upload_path(conn, :update, upload), upload: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    upload = Repo.insert! %Upload{}
    conn = delete conn, upload_path(conn, :delete, upload)
    assert response(conn, 204)
    refute Repo.get(Upload, upload.id)
  end
end
