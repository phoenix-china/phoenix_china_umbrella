defmodule PhoenixChina.UserContextTest do
  use PhoenixChina.DataCase

  alias PhoenixChina.UserContext
  alias PhoenixChina.Models.User

  @create_attrs %{nickname: "nanlong", email: "test@phoenix-china.org", password: "123456"}
  @update_attrs %{nickname: "昵称测试", password: "654321"}
  @invalid_attrs %{nicknme: nil, email: nil, password: nil}

  def fixture(:user, attrs \\ @create_attrs) do
    {:ok, user} = UserContext.create(attrs)
    %{user | password: nil}
  end

  test "list/1 returns all users" do
    user = fixture(:user)
    assert UserContext.list() == [user]
  end

  test "get! returns the user with given id" do
    user = fixture(:user)
    assert UserContext.get!(user.id) == user
  end

  test "create/1 with valid data creates a user" do
    assert {:ok, %User{} = user} = UserContext.create(@create_attrs)
    assert user.nickname == "nanlong"
  end

  test "create/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = UserContext.create(@invalid_attrs)
  end

  test "update/2 with valid data updates the user" do
    user = fixture(:user)
    assert {:ok, user} = UserContext.update(user, @update_attrs)
    assert %User{} = user
    assert user.nickname == "昵称测试"
  end

  test "update/2 with invalid data returns error changeset" do
    user = fixture(:user)
    assert {:error, %Ecto.Changeset{}} = UserContext.update(user, @invalid_attrs)
    assert user == UserContext.get!(user.id)
  end

  test "delete/1 deletes the user" do
    user = fixture(:user)
    assert {:ok, %User{}} = UserContext.delete(user)
    assert_raise Ecto.NoResultsError, fn -> UserContext.get!(user.id) end
  end

  test "update/2 with valid data for password reset" do
    user = fixture(:user)
    token = UserContext.generate_token(user)
    assert {:ok, user} = UserContext.update(token, %{"password" => "passwordreset", "password_confirmation" => "passwordreset"})
    assert UserContext.checkpw(user, "passwordreset")
  end

  test "update/2 with invalid token for password reset" do
    token = "error token"
    assert {:error, :invalid} = UserContext.update(token, %{"password" => "passwordreset", "password_confirmation" => "passwordreset"})
  end

  test "update/2 with expired token for password reset" do
    user = fixture(:user)
    token = UserContext.generate_token(user, System.system_time(:seconds) - (60 * 60 * 12))
    assert {:error, :expired} = UserContext.update(token, %{"password" => "passwordreset", "password_confirmation" => "passwordreset"})
  end
end