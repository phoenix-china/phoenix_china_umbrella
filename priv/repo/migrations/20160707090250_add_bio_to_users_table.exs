defmodule PhoenixChina.Repo.Migrations.AddBioToUsersTable do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :bio, :string, default: ""
    end
  end
end
