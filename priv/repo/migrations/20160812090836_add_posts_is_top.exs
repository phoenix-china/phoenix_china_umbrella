defmodule PhoenixChina.Repo.Migrations.AddPostsIsTop do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :is_top, :boolean
    end
  end
end
