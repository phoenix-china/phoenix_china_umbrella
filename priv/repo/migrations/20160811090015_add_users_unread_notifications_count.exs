defmodule PhoenixChina.Repo.Migrations.AddUsersUnreadNotificationsCount do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :unread_notifications_count, :integer
    end
  end
end
