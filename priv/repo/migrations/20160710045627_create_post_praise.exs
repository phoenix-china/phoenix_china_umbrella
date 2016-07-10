defmodule PhoenixChina.Repo.Migrations.CreatePostPraise do
  use Ecto.Migration

  def change do
    create table(:post_praises) do
      add :user_id, references(:users, on_delete: :nothing)
      add :post_id, references(:posts, on_delete: :nothing)

      timestamps()
    end
    create index(:post_praises, [:user_id])
    create index(:post_praises, [:post_id])

  end
end
