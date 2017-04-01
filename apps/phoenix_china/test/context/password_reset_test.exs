defmodule PhoenixChina.PasswordResetContextTest do
  use PhoenixChina.DataCase

  alias PhoenixChina.UserContext
  alias PhoenixChina.PasswordResetContext

  @user_attrs %{email: "test@phoenix-china.org", nickname: "nanlong", password: "123456"}
  @create_attrs %{email: "test@phoenix-china.org"}
  @invalid_attrs %{email: nil}

  def fixture(:user, attrs \\ @user_attrs) do
    {:ok, user} = UserContext.create(attrs)
    %{user | password: nil}
  end

  test "create/1 with valid data" do
    user = fixture(:user)
    assert {:ok, change_user} = PasswordResetContext.create(@create_attrs)
    assert user == change_user
  end

  test "create/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = PasswordResetContext.create(@invalid_attrs)
  end
end