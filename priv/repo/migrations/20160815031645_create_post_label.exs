defmodule PhoenixChina.Repo.Migrations.CreatePostLabel do
  use Ecto.Migration

  def change do
    create table(:post_labels) do
      add :content, :string

      timestamps()
    end
    create index(:post_labels, [:content])

    alter table(:posts) do
      add :label_id, references(:post_labels, on_delete: :nothing)
    end
    create index(:posts, [:label_id])
  end
end
