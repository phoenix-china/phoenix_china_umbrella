defmodule PhoenixChina.Repo.Migrations.DropUsersIndexNickname do
  use Ecto.Migration

  def change do
    drop index(:users, [:nickname])
  end
end
