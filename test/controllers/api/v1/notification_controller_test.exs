defmodule PhoenixChina.API.V1.NotificationControllerTest do
  use PhoenixChina.ConnCase

  alias PhoenixChina.API.V1.Notification
  @valid_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, notification_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    notification = Repo.insert! %Notification{}
    conn = get conn, notification_path(conn, :show, notification)
    assert json_response(conn, 200)["data"] == %{"id" => notification.id}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, notification_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, notification_path(conn, :create), notification: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Notification, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, notification_path(conn, :create), notification: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    notification = Repo.insert! %Notification{}
    conn = put conn, notification_path(conn, :update, notification), notification: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Notification, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    notification = Repo.insert! %Notification{}
    conn = put conn, notification_path(conn, :update, notification), notification: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    notification = Repo.insert! %Notification{}
    conn = delete conn, notification_path(conn, :delete, notification)
    assert response(conn, 204)
    refute Repo.get(Notification, notification.id)
  end
end
