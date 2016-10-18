defmodule PhoenixChina.Repo.Migrations.AddCommentIsDeleted do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      add :is_deleted, :boolean, default: false
    end
    
  end
end
