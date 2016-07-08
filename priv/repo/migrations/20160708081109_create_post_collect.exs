defmodule PhoenixChina.Repo.Migrations.CreatePostCollect do
  use Ecto.Migration

  def change do
    create table(:post_collects) do
      add :user_id, references(:users, on_delete: :nothing)
      add :post_id, references(:posts, on_delete: :nothing)

      timestamps()
    end
    create index(:post_collects, [:user_id])
    create index(:post_collects, [:post_id])

  end
end
