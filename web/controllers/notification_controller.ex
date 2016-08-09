defmodule PhoenixChina.NotificationController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.Notification

  import PhoenixChina.ViewHelpers, only: [current_user: 1]

  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixChina.GuardianHandler]
    when action in [:default]


  def default(conn, params) do
    current_user = current_user(conn)

    page = Notification
    |> where(user_id: ^current_user.id)
    |> order_by(desc: :inserted_at)
    |> Repo.paginate(params)

    conn
    |> render("default_page.json", page: page)
  end

  def default(conn, %{}) do
    default(conn, %{"page" => 1})
  end

end
