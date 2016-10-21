defmodule PhoenixChina.Repo.Migrations.AddPostIsClosed do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :is_closed, :boolean, default: false
    end
  end
end
