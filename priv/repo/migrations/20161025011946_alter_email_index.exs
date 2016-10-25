defmodule PhoenixChina.Repo.Migrations.AlterEmailIndex do
  use Ecto.Migration

  def change do
    # 移除旧索引
    drop index(:users, [:email])
    # 增加新索引
    create unique_index(:users, ["lower(email)"])
  end
end
