defmodule PhoenixChina.Repo.Migrations.AddPostlabelsIndexAndIsHidden do
  use Ecto.Migration

  def change do
    alter table(:post_labels) do
      add :order, :integer
      add :is_hide, :boolean
    end

    create index(:post_labels, [:order])
    create index(:post_labels, [:is_hide])
  end
end
