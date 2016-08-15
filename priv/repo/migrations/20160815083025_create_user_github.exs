defmodule PhoenixChina.Repo.Migrations.CreateUserGithub do
  use Ecto.Migration

  def change do
    create table(:users_github) do
      add :github_id, :string
      add :github_url, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:users_github, [:user_id])
    create index(:users_github, [:github_id])

  end
end
