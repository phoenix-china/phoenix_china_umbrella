defmodule PhoenixChina.PostLabelTest do
  use PhoenixChina.ModelCase

  alias PhoenixChina.PostLabel

  @valid_attrs %{content: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = PostLabel.changeset(%PostLabel{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = PostLabel.changeset(%PostLabel{}, @invalid_attrs)
    refute changeset.valid?
  end
end
