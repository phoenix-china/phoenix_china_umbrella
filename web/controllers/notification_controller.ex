defmodule PhoenixChina.NotificationController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.{User, Notification}

  import PhoenixChina.ViewHelpers, only: [current_user: 1]
  import PhoenixChina.ModelOperator, only: [set: 4]

  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixChina.GuardianErrorHandler]

  def index(conn, params) do
    current_user = current_user(conn)

    User |> set(current_user, :unread_notifications_count, 0)

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
