defmodule PhoenixChina.UserTest do
  use PhoenixChina.ModelCase

  alias PhoenixChina.User

  @valid_attrs %{email: "some content", nickname: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
