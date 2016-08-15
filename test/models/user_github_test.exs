defmodule PhoenixChina.UserGithubTest do
  use PhoenixChina.ModelCase

  alias PhoenixChina.UserGithub

  @valid_attrs %{github_id: "some content", github_url: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = UserGithub.changeset(%UserGithub{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = UserGithub.changeset(%UserGithub{}, @invalid_attrs)
    refute changeset.valid?
  end
end
