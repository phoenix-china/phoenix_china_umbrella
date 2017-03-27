defmodule PhoenixChina.UserContext do
  import Ecto.{Query, Changeset}, warn: false
  alias PhoenixChina.Repo

  alias PhoenixChina.Models.User

  def list do
    Repo.all(User)
  end

  def get!(id) do
    Repo.get!(User, id)
  end

  def create(attrs \\ %{}) do
    :create
    |> change_user(attrs)
    |> Repo.insert()
  end

  def update(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(:create, attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
  end
end