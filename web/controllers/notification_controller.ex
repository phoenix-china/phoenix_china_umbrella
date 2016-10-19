defmodule PhoenixChina.NotificationController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.{Notification}

  import PhoenixChina.ViewHelpers, only: [current_user: 1]
  import PhoenixChina.Ecto.Helpers, only: [update_field: 3]

  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixChina.GuardianErrorHandler]

  def index(conn, params) do
    current_user = current_user(conn)
    |> update_field(:unread_notifications_count, 0)

    pagination = Notification
    |> where(user_id: ^current_user.id)
    |> order_by([desc: :inserted_at])
    |> Repo.paginate(params)

    conn
    |> assign(:title, "消息")
    |> assign(:pagination, pagination)
    |> render("index.html")
  end
end
