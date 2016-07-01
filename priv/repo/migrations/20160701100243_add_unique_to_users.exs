defmodule PhoenixChina.Repo.Migrations.AddUniqueToUsers do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:email])
    create unique_index(:users, [:nickname])
  end
end
