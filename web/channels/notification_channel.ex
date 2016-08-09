defmodule PhoenixChina.NotificationChannel do
  use Phoenix.Channel

  def join("notifications:" <> user_id, _params, socket) do
    {:ok, socket}

    # {:error, %{reason: "unauthorized"}}
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
