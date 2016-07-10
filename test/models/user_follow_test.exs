defmodule PhoenixChina.UserFollowTest do
  use PhoenixChina.ModelCase

  alias PhoenixChina.UserFollow

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = UserFollow.changeset(%UserFollow{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = UserFollow.changeset(%UserFollow{}, @invalid_attrs)
    refute changeset.valid?
  end
end
