defmodule PhoenixChina.Repo.Migrations.AddCollectCountToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :collect_count, :integer, default: 0
    end
  end
end
