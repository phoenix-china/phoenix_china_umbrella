defmodule PhoenixChina.Repo.Migrations.AddPostLatestCommentInsertedAt do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :latest_comment_inserted_at, :datetime
    end
  end
end
