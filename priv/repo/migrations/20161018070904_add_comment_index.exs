defmodule PhoenixChina.Repo.Migrations.AddCommentIndex do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      add :index, :integer
    end
    create index(:comments, [:index])
  end
end
