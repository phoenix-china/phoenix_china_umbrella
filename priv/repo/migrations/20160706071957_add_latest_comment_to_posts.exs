defmodule PhoenixChina.Repo.Migrations.AddLatestCommentToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :comment_count, :integer, default: 0
      add :collect_count, :integer, default: 0
      add :praise_count, :integer, default: 0
      add :latest_comment_id, references(:comments), null: true
    end
  end
end
