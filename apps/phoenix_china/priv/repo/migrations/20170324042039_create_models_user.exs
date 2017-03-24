defmodule PhoenixChina.Repo.Migrations.CreatePhoenixChina.Models.User do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string
      add :password_hash, :string
      add :nickname, :string
      add :avatar, :string

      timestamps()
    end

    create unique_index(:users, ["lower(email)"])
    create index(:users, [:nickname])
  end
end
