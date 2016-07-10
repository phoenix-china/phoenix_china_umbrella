defmodule PhoenixChina.Repo.Migrations.CreateCommentPraise do
  use Ecto.Migration

  def change do
    create table(:comment_praises) do
      add :user_id, references(:users, on_delete: :nothing)
      add :comment_id, references(:comments, on_delete: :nothing)

      timestamps()
    end
    create index(:comment_praises, [:user_id])
    create index(:comment_praises, [:comment_id])

    alter table(:comments) do
      add :praise_count, :integer, default: 0
    end

  end
end
