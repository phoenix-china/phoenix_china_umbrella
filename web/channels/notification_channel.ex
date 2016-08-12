defmodule PhoenixChina.NotificationChannel do
  use Phoenix.Channel
  import Guardian.Phoenix.Socket

  def join("notifications:" <> _user_id, %{"guardian_token" => token}, socket) do
    case sign_in(socket, token) do
      {:ok, authed_socket, _guardian_params} ->
        {:ok, %{message: "Joined"}, authed_socket}
      {:error, reason} ->
        {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in(event, msg, socket) do
    broadcast! socket, event, msg
    {:noreply, socket}
  end

  # def handle_in("new_msg", msg, socket) do
  #   # PhoenixChina.Endpoint.broadcast "rooms:lobby", "new_msg", %{"user" => "Boris", "body" => "test msg"}
  #   # 链接名称， 事件， 内容
  #   broadcast! socket, "new_msg", msg
  #   {:noreply, socket}
  # end
end
