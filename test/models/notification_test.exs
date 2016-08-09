defmodule PhoenixChina.NotificationTest do
  use PhoenixChina.ModelCase

  alias PhoenixChina.Notification

  @valid_attrs %{action: "some content", data_id: 42, html: "some content", json: %{}}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Notification.changeset(%Notification{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Notification.changeset(%Notification{}, @invalid_attrs)
    refute changeset.valid?
  end
end
