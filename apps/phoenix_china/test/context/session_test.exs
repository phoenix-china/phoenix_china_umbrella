defmodule PhoenixChina.SessionContextTest do
  use PhoenixChina.DataCase

  alias PhoenixChina.UserContext
  alias PhoenixChina.SessionContext

  @user_attrs %{email: "test@phoenix-china.org", nickname: "nanlong", password: "123456"}
  @create_attrs %{email: "test@phoenix-china.org", password: "123456"}
  @invalid_attrs %{email: nil, password: nil}

  def fixture(:user, attrs \\ @user_attrs) do
    {:ok, user} = UserContext.create(attrs)
    %{user | password: nil}
  end

  test "create/1 with valid data creates a session" do
    user = fixture(:user)
    assert {:ok, session} = SessionContext.create(@create_attrs)
    assert user == session
  end

  test "create/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = SessionContext.create(@invalid_attrs)
  end
end