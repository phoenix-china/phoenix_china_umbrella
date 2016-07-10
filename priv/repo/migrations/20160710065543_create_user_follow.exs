defmodule PhoenixChina.Repo.Migrations.CreateUserFollow do
  use Ecto.Migration

  def change do
    create table(:user_follows) do
      add :user_id, references(:users, on_delete: :nothing)
      add :to_user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:user_follows, [:user_id])
    create index(:user_follows, [:to_user_id])

    alter table(:users) do
      add :follower_count, :integer, default: 0
      add :followed_count, :integer, default: 0
    end
  end
end
