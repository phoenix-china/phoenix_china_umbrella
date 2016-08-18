defmodule PhoenixChina.Repo.Migrations.AddUsersUsername do
  use Ecto.Migration

  def change do
    drop index(:users, [:nickname])
    
    rename table(:users), :nickname, to: :username

    alter table(:users) do
      add :nickname, :string
    end

    create unique_index(:users, [:username])
    create unique_index(:users, [:nickname])
  end
end
