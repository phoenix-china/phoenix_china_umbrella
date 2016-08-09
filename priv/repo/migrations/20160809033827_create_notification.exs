defmodule PhoenixChina.Repo.Migrations.CreateNotification do
  use Ecto.Migration

  def change do
    create table(:notificatons) do
      add :action, :string
      add :data_id, :integer
      add :html, :text
      add :json, :map
      add :user_id, references(:users, on_delete: :nothing)
      add :operator_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:notificatons, [:user_id])
    create index(:notificatons, [:operator_id])

  end
end
